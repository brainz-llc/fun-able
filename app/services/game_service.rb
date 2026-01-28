class GameService
  class Error < StandardError; end

  attr_reader :game

  def initialize(game)
    @game = game
  end

  def self.create_game(host, **options)
    game = Game.new(
      host: host,
      deck_id: options[:deck_id],
      points_to_win: options[:points_to_win] || 10,
      turn_timer: options[:turn_timer] || 60,
      max_players: options[:max_players] || 10
    )

    if game.save
      game.add_player!(host)
      game
    else
      raise Error, game.errors.full_messages.join(', ')
    end
  end

  def self.join_game(user, code)
    game = Game.find_by_code(code)
    raise Error, 'Partida no encontrada' unless game
    raise Error, 'La partida ya comenzó' unless game.lobby?
    raise Error, 'La partida está llena' if game.full?

    player = game.add_player!(user)
    raise Error, 'No se pudo unir' unless player

    GameChannel.broadcast_player_joined(game, player)
    player
  end

  def start_game!
    raise Error, 'No se puede iniciar' unless game.can_start?

    game.transaction do
      game.update!(status: :playing)
      deal_initial_hands!
      create_first_round!
    end

    GameChannel.broadcast_game_started(game)
    schedule_timer!
    game.current_round
  end

  def submit_cards!(player, card_ids)
    round = game.current_round
    raise Error, 'No hay ronda activa' unless round
    raise Error, 'No es momento de enviar cartas' unless round.submitting?
    raise Error, 'Eres el Zar' if player.current_judge?
    raise Error, 'Ya enviaste cartas' if player.submitted_for_round?(round)
    raise Error, 'Cartas inválidas' unless player.has_cards?(card_ids)

    expected = round.pick_count
    raise Error, "Necesitas #{expected} carta(s)" if card_ids.length != expected

    submission = nil
    game.transaction do
      submission = round.card_submissions.create!(player: player)
      card_ids.each_with_index do |card_id, index|
        submission.submission_cards.create!(card_id: card_id, play_order: index + 1)
      end
      player.remove_cards_from_hand!(card_ids)
    end

    GameChannel.broadcast_card_submitted(game, round)

    if round.all_submitted?
      advance_to_judging!
    end

    submission
  end

  def advance_to_judging!
    round = game.current_round
    return unless round&.can_advance_to_judging?

    round.advance_to_judging!
    GameChannel.broadcast_judging_started(game, round)
    schedule_timer!
  end

  def select_winner!(judge_player, submission_id)
    round = game.current_round
    raise Error, 'No es momento de seleccionar' unless round&.judging? || round&.revealing?
    raise Error, 'No eres el Zar' unless judge_player.current_judge?

    submission = round.card_submissions.find(submission_id)
    raise Error, 'Selección inválida' unless submission

    game.transaction do
      round.select_winner!(submission)
    end

    GameChannel.broadcast_winner_selected(game, round, submission)

    if game.finished?
      GameChannel.broadcast_game_ended(game)
    else
      # New round was created in select_winner!
      new_round = game.current_round
      GameChannel.broadcast_new_round(game, new_round)
      schedule_timer!
    end

    submission
  end

  def handle_timer_expired!
    round = game.current_round
    return unless round

    case round.phase
    when 'submitting'
      # Auto-submit random cards for players who haven't submitted
      auto_submit_for_missing_players!
      advance_to_judging!
    when 'judging'
      # Auto-select random winner
      auto_select_winner!
    end
  end

  def player_disconnected!(player)
    return if player.connected?
    return unless game.playing?

    # If it's been too long, remove the player
    if player.disconnected_at && player.disconnected_at < 30.seconds.ago
      handle_player_abandonment!(player)
    end
  end

  private

  def deal_initial_hands!
    game.active_players.each do |player|
      player.deal_cards_to_hand_size!
    end
  end

  def create_first_round!
    first_judge = game.active_players.order(:position).first
    first_black_card = game.deck.black_cards.shuffled.first

    game.rounds.create!(
      round_number: 1,
      judge: first_judge,
      black_card: first_black_card,
      phase: :submitting,
      timer_expires_at: game.turn_timer.seconds.from_now
    )
  end

  def schedule_timer!
    round = game.current_round
    return unless round&.timer_expires_at

    RoundTimerExpiredJob.set(wait_until: round.timer_expires_at).perform_later(game.id, round.id)
  end

  def auto_submit_for_missing_players!
    round = game.current_round
    submitted_player_ids = round.card_submissions.pluck(:player_id)

    game.active_players.where.not(id: [round.judge_id] + submitted_player_ids).each do |player|
      # Pick random cards from hand
      random_cards = player.cards_in_hand.sample(round.pick_count)
      next if random_cards.length < round.pick_count

      begin
        submission = round.card_submissions.create!(player: player)
        random_cards.each_with_index do |card, index|
          submission.submission_cards.create!(card: card, play_order: index + 1)
        end
        player.remove_cards_from_hand!(random_cards.map(&:id))
      rescue => e
        Rails.logger.error("Auto-submit failed for player #{player.id}: #{e.message}")
      end
    end
  end

  def auto_select_winner!
    round = game.current_round
    return unless round&.judging?

    random_submission = round.card_submissions.sample
    return unless random_submission

    game.transaction do
      round.select_winner!(random_submission)
    end

    GameChannel.broadcast_winner_selected(game, round, random_submission)

    if game.finished?
      GameChannel.broadcast_game_ended(game)
    else
      new_round = game.current_round
      GameChannel.broadcast_new_round(game, new_round)
      schedule_timer!
    end
  end

  def handle_player_abandonment!(player)
    round = game.current_round

    # If they were the judge, auto-select and continue
    if player.current_judge? && round&.judging?
      auto_select_winner!
    end

    player.leave!
    GameChannel.broadcast_player_left(game, player)

    # Check if enough players remain
    if game.player_count < 3
      game.finish!
      GameChannel.broadcast_game_ended(game)
    end
  end
end
