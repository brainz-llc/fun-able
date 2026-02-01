class MostLikelyToController < ApplicationController
  before_action :require_login, except: [:show, :join]
  before_action :set_game, only: [:show, :lobby, :join, :play]
  before_action :set_game_from_game_id, only: [:start, :vote, :reveal, :next_round, :leave]
  before_action :require_game_player, only: [:lobby, :play, :vote, :reveal, :next_round, :leave]
  before_action :require_game_host, only: [:start, :reveal, :next_round]

  def index
    redirect_to new_most_likely_to_path
  end

  def new
    create_or_find_guest! unless logged_in?
    @game = MostLikelyToGame.new(
      total_rounds: 10,
      max_players: 10
    )
  end

  def create
    create_or_find_guest! unless logged_in?

    @game = MostLikelyToGame.new(game_params)
    @game.host = current_user

    if @game.save
      @game.add_player!(current_user)
      redirect_to most_likely_to_lobby_path(@game)
    else
      flash.now[:alert] = @game.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def show
    if @game.lobby?
      redirect_to most_likely_to_lobby_path(@game)
    elsif @game.playing?
      redirect_to most_likely_to_play_path(@game)
    else
      render :finished
    end
  end

  def lobby
    @players = @game.most_likely_to_players.includes(:user).by_position
  end

  def join
    create_or_find_guest! unless logged_in?

    if @game.has_player?(current_user)
      redirect_to most_likely_to_path(@game)
      return
    end

    unless @game.joinable?
      redirect_to root_path, alert: 'No puedes unirte a esta partida'
      return
    end

    player = @game.add_player!(current_user)

    if player
      MostLikelyToChannel.broadcast_player_joined(@game, player)
      redirect_to most_likely_to_lobby_path(@game)
    else
      redirect_to root_path, alert: 'No se pudo unir a la partida'
    end
  end

  def join_by_code
    code = params[:code]&.to_s&.upcase&.strip&.gsub(/[^A-Z0-9]/, '')
    game = MostLikelyToGame.find_by_code(code)

    if game
      redirect_to most_likely_to_join_path(game)
    else
      redirect_to root_path, alert: "Codigo de partida invalido: #{code}"
    end
  end

  def play
    unless @game.playing?
      redirect_to most_likely_to_path(@game)
      return
    end
    @players = @game.active_players.includes(:user)
  end

  def start
    unless @game.can_start?
      redirect_to most_likely_to_lobby_path(@game), alert: 'Se necesitan al menos 3 jugadores'
      return
    end

    if @game.start!
      MostLikelyToChannel.broadcast_game_started(@game)
      redirect_to most_likely_to_play_path(@game)
    else
      redirect_to most_likely_to_lobby_path(@game), alert: 'No se pudo iniciar la partida'
    end
  end

  def vote
    target_player = @game.most_likely_to_players.find_by(id: params[:player_id])

    unless target_player
      render json: { error: 'Jugador no encontrado' }, status: :not_found
      return
    end

    if @current_player.has_voted_this_round?
      render json: { error: 'Ya votaste esta ronda' }, status: :unprocessable_entity
      return
    end

    if @current_player.vote_for!(target_player)
      MostLikelyToChannel.broadcast_vote_received(@game, @current_player)

      # Auto-reveal if all voted
      if @game.all_voted?
        @game.reveal_results!
        MostLikelyToChannel.broadcast_reveal_results(@game)
      end

      render json: { success: true, all_voted: @game.all_voted? }
    else
      render json: { error: 'No se pudo registrar el voto' }, status: :unprocessable_entity
    end
  end

  def reveal
    @game.reveal_results!
    MostLikelyToChannel.broadcast_reveal_results(@game)
    render json: { success: true }
  end

  def next_round
    if @game.next_round!
      MostLikelyToChannel.broadcast_new_round(@game)
      render json: { success: true, round: @game.current_round }
    else
      MostLikelyToChannel.broadcast_game_ended(@game)
      render json: { success: true, finished: true }
    end
  end

  def leave
    @game.remove_player!(current_user)
    MostLikelyToChannel.broadcast_player_left(@game, @current_player)
    redirect_to root_path, notice: 'Has abandonado la partida'
  end

  private

  def set_game
    @game = MostLikelyToGame.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Partida no encontrada'
  end

  def set_game_from_game_id
    @game = MostLikelyToGame.find(params[:most_likely_to_id] || params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Partida no encontrada'
  end

  def require_game_player
    @current_player = @game.player_for(current_user)
    unless @current_player
      redirect_to root_path, alert: 'No eres parte de esta partida'
    end
  end

  def require_game_host
    unless @game.host?(current_user)
      redirect_to most_likely_to_path(@game), alert: 'Solo el anfitrion puede hacer esto'
    end
  end

  def game_params
    params.require(:most_likely_to_game).permit(:total_rounds, :max_players)
  end

  helper_method :current_mlt_game, :current_mlt_player, :mlt_game_host?

  def current_mlt_game
    @game
  end

  def current_mlt_player
    @current_player ||= @game&.player_for(current_user)
  end

  def mlt_game_host?
    @game&.host?(current_user)
  end
end
