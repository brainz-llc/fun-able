class NeverHaveIEverActionsController < ApplicationController
  include NeverHaveIEverAuthorizable

  before_action :require_login
  before_action :require_nhie_game_player

  def start
    unless nhie_game_host?
      redirect_to never_have_i_ever_game_path(current_nhie_game), alert: 'Solo el anfitrion puede iniciar'
      return
    end

    unless current_nhie_game.can_start?
      redirect_to lobby_never_have_i_ever_game_path(current_nhie_game), alert: 'No se puede iniciar la partida'
      return
    end

    if current_nhie_game.start!
      NeverHaveIEverChannel.broadcast_game_started(current_nhie_game)
      redirect_to never_have_i_ever_game_path(current_nhie_game)
    else
      redirect_to lobby_never_have_i_ever_game_path(current_nhie_game), alert: 'Error al iniciar'
    end
  end

  def drink
    unless current_nhie_game.playing?
      render json: { error: 'La partida no esta activa' }, status: :unprocessable_entity
      return
    end

    if current_nhie_player.drank_this_round?
      render json: { error: 'Ya bebiste esta ronda' }, status: :unprocessable_entity
      return
    end

    current_nhie_player.drink!
    NeverHaveIEverChannel.broadcast_player_drank(current_nhie_game, current_nhie_player)

    render json: { success: true, points: current_nhie_player.points }
  end

  def next_card
    unless nhie_game_host? || current_nhie_player.current_reader?
      render json: { error: 'Solo el lector puede avanzar' }, status: :unprocessable_entity
      return
    end

    unless current_nhie_game.playing?
      render json: { error: 'La partida no esta activa' }, status: :unprocessable_entity
      return
    end

    current_nhie_game.next_round!

    if current_nhie_game.finished?
      redirect_to never_have_i_ever_game_path(current_nhie_game)
    else
      NeverHaveIEverChannel.broadcast_new_card(current_nhie_game)
      render json: { success: true }
    end
  end

  def leave
    current_nhie_player.leave!
    NeverHaveIEverChannel.broadcast_player_left(current_nhie_game, current_nhie_player)
    redirect_to never_have_i_ever_path, notice: 'Has abandonado la partida'
  end

  def kick
    unless nhie_game_host?
      redirect_to never_have_i_ever_game_path(current_nhie_game), alert: 'Solo el anfitrion puede expulsar'
      return
    end

    player = current_nhie_game.never_have_i_ever_players.find(params[:player_id])

    if player.user_id == current_user.id
      redirect_to never_have_i_ever_game_path(current_nhie_game), alert: 'No puedes expulsarte a ti mismo'
      return
    end

    player.kick!
    NeverHaveIEverChannel.broadcast_player_kicked(current_nhie_game, player)
    redirect_to lobby_never_have_i_ever_game_path(current_nhie_game), notice: "#{player.display_name} ha sido expulsado"
  end

  def update_settings
    unless nhie_game_host?
      redirect_to lobby_never_have_i_ever_game_path(current_nhie_game), alert: 'Solo el anfitrion puede cambiar la configuracion'
      return
    end

    unless current_nhie_game.lobby?
      redirect_to never_have_i_ever_game_path(current_nhie_game), alert: 'No se puede cambiar durante el juego'
      return
    end

    if current_nhie_game.update(settings_params)
      NeverHaveIEverChannel.broadcast_settings_updated(current_nhie_game)
      redirect_to lobby_never_have_i_ever_game_path(current_nhie_game), notice: 'Configuracion actualizada'
    else
      redirect_to lobby_never_have_i_ever_game_path(current_nhie_game), alert: current_nhie_game.errors.full_messages.join(', ')
    end
  end

  private

  def settings_params
    params.require(:never_have_i_ever_game).permit(:category, :starting_points, :max_players)
  end
end
