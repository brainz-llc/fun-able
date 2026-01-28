class GameChannel < ApplicationCable::Channel
  def subscribed
    @game = Game.find(params[:game_id])
    @game_player = @game.player_for(current_user)

    if @game_player
      stream_from broadcast_channel
      @game_player.mark_connected!
      broadcast_player_status_changed
    else
      reject
    end
  end

  def unsubscribed
    return unless @game_player

    @game_player.mark_disconnected!
    broadcast_player_status_changed

    # Schedule disconnection handling if game is in progress
    if @game.playing?
      HandleDisconnectionJob.set(wait: 30.seconds).perform_later(@game_player.id)
    end
  end

  # Client actions
  def ping
    transmit({ type: 'pong', timestamp: Time.current.to_i })
  end

  def request_state
    transmit({
      type: 'game_state',
      game: game_state,
      player: player_state
    })
  end

  # Class methods for broadcasting
  class << self
    def broadcast_to_game(game, data)
      ActionCable.server.broadcast("game_#{game.id}", data)
    end

    def broadcast_player_joined(game, player)
      broadcast_to_game(game, {
        type: 'player_joined',
        player: player_data(player),
        player_count: game.player_count
      })
    end

    def broadcast_player_left(game, player)
      broadcast_to_game(game, {
        type: 'player_left',
        player_id: player.id,
        user_id: player.user_id,
        player_count: game.player_count
      })
    end

    def broadcast_player_kicked(game, player)
      broadcast_to_game(game, {
        type: 'player_kicked',
        player_id: player.id,
        user_id: player.user_id
      })
    end

    def broadcast_settings_updated(game)
      broadcast_to_game(game, {
        type: 'settings_updated',
        settings: {
          deck_id: game.deck_id,
          points_to_win: game.points_to_win,
          turn_timer: game.turn_timer,
          max_players: game.max_players
        }
      })
    end

    def broadcast_game_started(game)
      round = game.current_round

      broadcast_to_game(game, {
        type: 'game_started',
        round: round_data(round),
        judge_id: round.judge_id
      })
    end

    def broadcast_new_round(game, round)
      broadcast_to_game(game, {
        type: 'new_round',
        round: round_data(round),
        judge_id: round.judge_id,
        leaderboard: leaderboard_data(game)
      })
    end

    def broadcast_card_submitted(game, round)
      broadcast_to_game(game, {
        type: 'card_submitted',
        submissions_count: round.submissions_count,
        expected_count: round.expected_submissions_count,
        all_submitted: round.all_submitted?
      })
    end

    def broadcast_judging_started(game, round)
      broadcast_to_game(game, {
        type: 'judging_started',
        round_id: round.id,
        submissions: submissions_data(round),
        timer_expires_at: round.timer_expires_at&.iso8601
      })
    end

    def broadcast_winner_selected(game, round, winning_submission)
      broadcast_to_game(game, {
        type: 'winner_selected',
        round_id: round.id,
        winning_submission_id: winning_submission.id,
        winner_player_id: winning_submission.player_id,
        winner_name: winning_submission.player.display_name,
        winning_cards: winning_submission.cards_in_order.map { |c| { id: c.id, content: c.content } },
        leaderboard: leaderboard_data(game)
      })
    end

    def broadcast_game_ended(game)
      winner = game.winner

      broadcast_to_game(game, {
        type: 'game_ended',
        winner_id: winner&.id,
        winner_name: winner&.display_name,
        winner_score: winner&.score,
        final_leaderboard: leaderboard_data(game)
      })
    end

    def broadcast_timer_update(game, round)
      broadcast_to_game(game, {
        type: 'timer_update',
        round_id: round.id,
        remaining: round.timer_remaining,
        expires_at: round.timer_expires_at&.iso8601
      })
    end

    private

    def player_data(player)
      {
        id: player.id,
        user_id: player.user_id,
        display_name: player.display_name,
        avatar_initials: player.avatar_initials,
        score: player.score,
        is_spectator: player.spectator?,
        is_host: player.host?,
        connected: player.connected?
      }
    end

    def round_data(round)
      {
        id: round.id,
        round_number: round.round_number,
        phase: round.phase,
        black_card: {
          id: round.black_card.id,
          content: round.black_card.content,
          pick_count: round.black_card.pick_count
        },
        judge_id: round.judge_id,
        timer_expires_at: round.timer_expires_at&.iso8601
      }
    end

    def submissions_data(round)
      round.submissions_for_display.map do |submission|
        {
          id: submission.id,
          reveal_order: submission.reveal_order,
          cards: submission.cards_in_order.map { |c| { id: c.id, content: c.content } }
        }
      end
    end

    def leaderboard_data(game)
      game.leaderboard.map do |player|
        {
          id: player.id,
          display_name: player.display_name,
          score: player.score
        }
      end
    end
  end

  private

  def broadcast_channel
    "game_#{@game.id}"
  end

  def broadcast_player_status_changed
    GameChannel.broadcast_to_game(@game, {
      type: 'player_status_changed',
      player_id: @game_player.id,
      connected: @game_player.connected?
    })
  end

  def game_state
    {
      id: @game.id,
      code: @game.code,
      status: @game.status,
      host_id: @game.host_id,
      deck_id: @game.deck_id,
      points_to_win: @game.points_to_win,
      turn_timer: @game.turn_timer,
      players: @game.game_players.includes(:user).map { |p| self.class.send(:player_data, p) },
      current_round: @game.current_round ? self.class.send(:round_data, @game.current_round) : nil
    }
  end

  def player_state
    return nil unless @game_player

    {
      id: @game_player.id,
      is_judge: @game_player.current_judge?,
      hand: @game_player.cards_in_hand.map { |c| { id: c.id, content: c.content, meme_url: c.meme_url } },
      submitted: @game.current_round ? @game_player.submitted_for_round?(@game.current_round) : false
    }
  end
end
