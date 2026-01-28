module GameAuthorizable
  extend ActiveSupport::Concern

  included do
    helper_method :current_game, :current_game_player, :game_host?
  end

  def current_game
    @current_game ||= Game.find(params[:game_id] || params[:id])
  end

  def current_game_player
    @current_game_player ||= current_game.player_for(current_user) if current_user && current_game
  end

  def game_host?
    current_game&.host?(current_user)
  end

  def require_game_player
    unless current_game_player
      redirect_to root_path, alert: 'No eres parte de esta partida'
    end
  end

  def require_game_host
    unless game_host?
      redirect_to game_path(current_game), alert: 'Solo el anfitrión puede hacer esto'
    end
  end

  def require_active_game
    unless current_game&.playing?
      redirect_to game_path(current_game), alert: 'La partida no está activa'
    end
  end

  def require_lobby
    unless current_game&.lobby?
      redirect_to game_path(current_game), alert: 'La partida ya comenzó'
    end
  end

  def require_current_judge
    unless current_game_player&.current_judge?
      redirect_to game_path(current_game), alert: 'No eres el Zar de las Cartas'
    end
  end

  def require_not_judge
    if current_game_player&.current_judge?
      redirect_to game_path(current_game), alert: 'El Zar no puede enviar cartas'
    end
  end
end
