class WouldYouRatherController < ApplicationController
  include Authenticatable

  before_action :set_game, only: [:show, :lobby, :join, :start, :vote, :next_round, :leave]
  before_action :require_player, only: [:show, :vote, :next_round, :leave]

  def index
    @active_games = WouldYouRatherGame.active.includes(:host).order(created_at: :desc).limit(10)
  end

  def new
    create_or_find_guest! unless logged_in?
    @game = WouldYouRatherGame.new(max_rounds: 10)
  end

  def create
    create_or_find_guest! unless logged_in?

    @game = WouldYouRatherGame.new(game_params)
    @game.host = current_user

    if @game.save
      @game.add_player!(current_user)
      redirect_to lobby_would_you_rather_path(@game)
    else
      flash.now[:alert] = @game.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def show
    if @game.lobby?
      redirect_to lobby_would_you_rather_path(@game)
    elsif @game.finished?
      render :finished
    else
      render :play
    end
  end

  def lobby
    create_or_find_guest! unless logged_in?

    unless @game.has_player?(current_user)
      if @game.joinable?
        @game.add_player!(current_user)
        WouldYouRatherChannel.broadcast_player_joined(@game, @game.player_for(current_user))
      else
        redirect_to would_you_rather_index_path, alert: 'No puedes unirte a esta partida'
        return
      end
    end

    @players = @game.would_you_rather_players.includes(:user)
    @current_player = @game.player_for(current_user)
  end

  def join
    create_or_find_guest! unless logged_in?

    if @game.has_player?(current_user)
      redirect_to would_you_rather_path(@game)
      return
    end

    unless @game.joinable?
      redirect_to would_you_rather_index_path, alert: 'No puedes unirte a esta partida'
      return
    end

    player = @game.add_player!(current_user)

    if player
      WouldYouRatherChannel.broadcast_player_joined(@game, player)
      redirect_to lobby_would_you_rather_path(@game)
    else
      redirect_to would_you_rather_index_path, alert: 'No se pudo unir a la partida'
    end
  end

  def join_by_code
    code = params[:code]&.to_s&.upcase&.strip&.gsub(/[^A-Z0-9]/, '')
    game = WouldYouRatherGame.find_by_code(code)

    if game
      redirect_to join_would_you_rather_path(game)
    else
      redirect_to would_you_rather_index_path, alert: "Codigo de partida invalido: #{code}"
    end
  end

  def start
    unless @game.host?(current_user)
      redirect_to would_you_rather_path(@game), alert: 'Solo el anfitrion puede iniciar el juego'
      return
    end

    if @game.start!
      WouldYouRatherChannel.broadcast_game_started(@game)
      redirect_to would_you_rather_path(@game)
    else
      redirect_to lobby_would_you_rather_path(@game), alert: 'No se puede iniciar el juego'
    end
  end

  def vote
    choice = params[:choice]

    unless %w[a b].include?(choice)
      render json: { error: 'Opcion invalida' }, status: :unprocessable_entity
      return
    end

    if @current_player.voted_for_round?(@game.current_round)
      render json: { error: 'Ya votaste en esta ronda' }, status: :unprocessable_entity
      return
    end

    vote = WouldYouRatherVote.create!(
      would_you_rather_game: @game,
      would_you_rather_player: @current_player,
      would_you_rather_card: @game.current_card,
      round_number: @game.current_round,
      choice: choice
    )

    WouldYouRatherChannel.broadcast_vote_submitted(@game)

    if @game.all_voted?
      results = @game.reveal_votes!
      WouldYouRatherChannel.broadcast_votes_revealed(@game, results)
    end

    render json: { success: true, all_voted: @game.all_voted? }
  end

  def next_round
    unless @game.host?(current_user)
      render json: { error: 'Solo el anfitrion puede avanzar' }, status: :unprocessable_entity
      return
    end

    @game.next_round!
    WouldYouRatherChannel.broadcast_new_round(@game)

    render json: { success: true }
  end

  def leave
    @game.remove_player!(current_user)
    WouldYouRatherChannel.broadcast_player_left(@game, @current_player)
    redirect_to would_you_rather_index_path, notice: 'Has abandonado la partida'
  end

  private

  def set_game
    @game = WouldYouRatherGame.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to would_you_rather_index_path, alert: 'Partida no encontrada'
  end

  def require_player
    @current_player = @game.player_for(current_user)
    unless @current_player
      redirect_to would_you_rather_index_path, alert: 'No eres parte de esta partida'
    end
  end

  def game_params
    params.require(:would_you_rather_game).permit(:max_rounds)
  end
end
