class GamesController < ApplicationController
  include GameAuthorizable

  before_action :require_login, except: [:show, :join]
  before_action :set_game, only: [:show, :lobby, :join]
  before_action :require_game_player, only: [:lobby]

  def new
    create_or_find_guest! unless logged_in?
    @game = Game.new(
      points_to_win: 10,
      turn_timer: 60,
      max_players: 10
    )
    @decks = Deck.published.includes(:region).popular
  end

  def create
    create_or_find_guest! unless logged_in?

    @game = Game.new(game_params)
    @game.host = current_user

    if @game.save
      @game.add_player!(current_user)
      redirect_to lobby_game_path(@game)
    else
      @decks = Deck.published.includes(:region).popular
      flash.now[:alert] = @game.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def show
    if current_game.lobby?
      redirect_to lobby_game_path(current_game)
    elsif current_game.playing? || current_game.paused?
      render :play
    else
      render :finished
    end
  end

  def lobby
    @players = current_game.game_players.includes(:user).by_position
    @decks = Deck.published.includes(:region).popular if game_host?
  end

  def join
    create_or_find_guest! unless logged_in?

    if current_game.has_player?(current_user)
      redirect_to game_path(current_game)
      return
    end

    unless current_game.joinable?
      redirect_to root_path, alert: 'No puedes unirte a esta partida'
      return
    end

    player = current_game.add_player!(current_user)

    if player
      GameChannel.broadcast_player_joined(current_game, player)
      redirect_to lobby_game_path(current_game)
    else
      redirect_to root_path, alert: 'No se pudo unir a la partida'
    end
  end

  def join_by_code
    code = params[:code]&.upcase&.strip
    game = Game.find_by_code(code)

    if game
      redirect_to join_game_path(game)
    else
      redirect_to root_path, alert: 'Código de partida inválido'
    end
  end

  private

  def set_game
    @current_game = Game.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Partida no encontrada'
  end

  def game_params
    params.require(:game).permit(:deck_id, :points_to_win, :turn_timer, :max_players)
  end
end
