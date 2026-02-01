module NeverHaveIEverAuthorizable
  extend ActiveSupport::Concern

  included do
    helper_method :current_nhie_game, :current_nhie_player, :nhie_game_host?
  end

  def current_nhie_game
    @current_nhie_game ||= NeverHaveIEverGame.find(params[:never_have_i_ever_game_id] || params[:id])
  end

  def current_nhie_player
    @current_nhie_player ||= current_nhie_game.player_for(current_user) if current_user && current_nhie_game
  end

  def nhie_game_host?
    current_nhie_game&.host?(current_user)
  end

  def require_nhie_game_player
    unless current_nhie_player
      redirect_to root_path, alert: 'No eres parte de esta partida'
    end
  end

  def require_nhie_game_host
    unless nhie_game_host?
      redirect_to never_have_i_ever_game_path(current_nhie_game), alert: 'Solo el anfitrion puede hacer esto'
    end
  end

  def require_nhie_active_game
    unless current_nhie_game&.playing?
      redirect_to never_have_i_ever_game_path(current_nhie_game), alert: 'La partida no esta activa'
    end
  end

  def require_nhie_lobby
    unless current_nhie_game&.lobby?
      redirect_to never_have_i_ever_game_path(current_nhie_game), alert: 'La partida ya comenzo'
    end
  end
end
