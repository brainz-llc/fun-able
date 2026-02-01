class NeverHaveIEverController < ApplicationController
  include NeverHaveIEverAuthorizable

  before_action :require_login, except: [:index, :show, :join]
  before_action :set_game, only: [:show, :lobby, :join]
  before_action :require_nhie_game_player, only: [:lobby]

  def index
    # Landing page for Never Have I Ever
  end

  def new
    create_or_find_guest! unless logged_in?
    @game = NeverHaveIEverGame.new(
      starting_points: 3,
      max_players: 10,
      category: :spicy
    )
  end

  def create
    create_or_find_guest! unless logged_in?

    @game = NeverHaveIEverGame.new(game_params)
    @game.host = current_user

    if @game.save
      @game.add_player!(current_user)
      redirect_to lobby_never_have_i_ever_game_path(@game)
    else
      flash.now[:alert] = @game.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def show
    if current_nhie_game.lobby?
      redirect_to lobby_never_have_i_ever_game_path(current_nhie_game)
    elsif current_nhie_game.playing? || current_nhie_game.paused?
      render :play
    else
      render :finished
    end
  end

  def lobby
    @players = current_nhie_game.never_have_i_ever_players.includes(:user).by_position
  end

  def join
    create_or_find_guest! unless logged_in?

    if current_nhie_game.has_player?(current_user)
      redirect_to never_have_i_ever_game_path(current_nhie_game)
      return
    end

    unless current_nhie_game.joinable?
      redirect_to never_have_i_ever_path, alert: 'No puedes unirte a esta partida'
      return
    end

    player = current_nhie_game.add_player!(current_user)

    if player
      NeverHaveIEverChannel.broadcast_player_joined(current_nhie_game, player)
      redirect_to lobby_never_have_i_ever_game_path(current_nhie_game)
    else
      redirect_to never_have_i_ever_path, alert: 'No se pudo unir a la partida'
    end
  end

  def join_by_code
    find_and_join_by_code
  end

  def join_by_code_link
    find_and_join_by_code
  end

  private

  def find_and_join_by_code
    raw_code = params[:code]
    code = raw_code&.to_s&.upcase&.strip&.gsub(/[^A-Z0-9]/, '')

    game = NeverHaveIEverGame.find_by_code(code)

    if game
      redirect_to join_never_have_i_ever_game_path(game)
    else
      redirect_to never_have_i_ever_path, alert: "Codigo de partida invalido: #{code}"
    end
  end

  def set_game
    @current_nhie_game = NeverHaveIEverGame.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to never_have_i_ever_path, alert: 'Partida no encontrada'
  end

  def game_params
    params.require(:never_have_i_ever_game).permit(:category, :starting_points, :max_players)
  end
end
