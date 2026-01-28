class GameActionsController < ApplicationController
  include GameAuthorizable

  before_action :require_login
  before_action :set_game
  before_action :require_game_player

  def start
    unless game_host?
      return respond_with_error('Solo el anfitrión puede iniciar la partida')
    end

    unless current_game.can_start?
      return respond_with_error('No se puede iniciar la partida. Verifica que haya suficientes jugadores y un mazo seleccionado.')
    end

    if current_game.start!
      GameChannel.broadcast_game_started(current_game)
      redirect_to game_path(current_game)
    else
      respond_with_error('Error al iniciar la partida')
    end
  end

  def submit_cards
    round = current_game.current_round

    unless round&.submitting?
      return respond_with_error('No puedes enviar cartas ahora')
    end

    if current_game_player.current_judge?
      return respond_with_error('El Zar no puede enviar cartas')
    end

    if current_game_player.submitted_for_round?(round)
      return respond_with_error('Ya enviaste tus cartas')
    end

    card_ids = params[:card_ids].to_a.map(&:to_i)

    if card_ids.length != round.pick_count
      return respond_with_error("Debes seleccionar #{round.pick_count} carta(s)")
    end

    unless current_game_player.has_cards?(card_ids)
      return respond_with_error('No tienes esas cartas')
    end

    submission = round.card_submissions.build(player: current_game_player)
    card_ids.each_with_index do |card_id, index|
      submission.submission_cards.build(card_id: card_id, play_order: index + 1)
    end

    if submission.save
      current_game_player.remove_cards_from_hand!(card_ids)

      # Check if all submitted and advance to judging
      round.reload
      if round.all_submitted?
        round.advance_to_judging!
        # Schedule timer for judging phase
        RoundTimerExpiredJob.set(wait_until: round.timer_expires_at).perform_later(current_game.id, round.id)
        # Broadcast after commit to ensure data is saved
        GameChannel.broadcast_judging_started(current_game, round)
      else
        GameChannel.broadcast_card_submitted(current_game, round)
      end

      respond_to do |format|
        format.html { redirect_to game_path(current_game) }
        format.turbo_stream
      end
    else
      respond_with_error(submission.errors.full_messages.join(', '))
    end
  end

  def select_winner
    round = current_game.current_round

    unless round&.judging? || round&.revealing?
      return respond_with_error('No puedes seleccionar ganador ahora')
    end

    unless current_game_player.current_judge?
      return respond_with_error('Solo el Zar puede seleccionar al ganador')
    end

    submission = round.card_submissions.find_by(id: params[:submission_id])

    unless submission
      return respond_with_error('Selección inválida')
    end

    if round.select_winner!(submission)
      GameChannel.broadcast_winner_selected(current_game, round, submission)

      # Delay the next round broadcast to allow winner animation to play
      # The client will handle the transition after showing the celebration
      if current_game.finished?
        # Game ended - client will show victory modal then redirect
        BroadcastNewRoundJob.set(wait: 6.seconds).perform_later(current_game.id, :game_ended)
      else
        # New round - client will show winner celebration then countdown
        BroadcastNewRoundJob.set(wait: 7.seconds).perform_later(current_game.id, :new_round)
      end

      respond_to do |format|
        format.html { redirect_to game_path(current_game) }
        format.json { render json: { success: true, winner_id: submission.player_id } }
        format.turbo_stream
      end
    else
      respond_with_error('Error al seleccionar ganador')
    end
  end

  def leave
    if game_host? && current_game.player_count > 1
      # Transfer host before leaving
      new_host = current_game.active_players.where.not(user: current_user).first&.user
      current_game.update!(host: new_host) if new_host
    end

    current_game_player.leave!
    GameChannel.broadcast_player_left(current_game, current_game_player)

    redirect_to root_path, notice: 'Has abandonado la partida'
  end

  def kick
    unless game_host?
      return respond_with_error('Solo el anfitrión puede expulsar jugadores')
    end

    player = current_game.game_players.find_by(id: params[:player_id])

    if player && player.user_id != current_user.id
      player.kick!
      GameChannel.broadcast_player_kicked(current_game, player)

      respond_to do |format|
        format.html { redirect_to lobby_game_path(current_game) }
        format.turbo_stream
      end
    else
      respond_with_error('No se puede expulsar a ese jugador')
    end
  end

  def update_settings
    unless game_host?
      return respond_with_error('Solo el anfitrión puede cambiar la configuración')
    end

    unless current_game.lobby?
      return respond_with_error('No puedes cambiar la configuración después de iniciar')
    end

    if current_game.update(settings_params)
      GameChannel.broadcast_settings_updated(current_game)

      respond_to do |format|
        format.html { redirect_to lobby_game_path(current_game) }
        format.turbo_stream
      end
    else
      respond_with_error(current_game.errors.full_messages.join(', '))
    end
  end

  private

  def set_game
    @current_game = Game.find(params[:game_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Partida no encontrada'
  end

  def settings_params
    params.require(:game).permit(:deck_id, :points_to_win, :turn_timer, :max_players)
  end

  def respond_with_error(message)
    respond_to do |format|
      format.html { redirect_to game_path(current_game), alert: message }
      format.turbo_stream { render turbo_stream: turbo_stream.replace('flash', partial: 'shared/flash', locals: { alert: message }) }
      format.json { render json: { error: message }, status: :unprocessable_entity }
    end
  end
end
