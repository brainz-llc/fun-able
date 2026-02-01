class TruthOrDareController < ApplicationController
  before_action :require_login, except: [:index, :show, :join]
  before_action :set_game, only: [:show, :lobby, :join, :play]
  before_action :require_game_player, only: [:lobby, :play]

  def index
    @games = TruthOrDareGame.joinable.recent.limit(10)
  end

  def new
    create_or_find_guest! unless logged_in?
    @game = TruthOrDareGame.new(
      max_players: 10,
      intensity_level: :mild
    )
  end

  def create
    create_or_find_guest! unless logged_in?

    @game = TruthOrDareGame.new(game_params)
    @game.host = current_user

    if @game.save
      @game.add_player!(current_user)
      redirect_to truth_or_dare_lobby_path(@game)
    else
      flash.now[:alert] = @game.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def show
    if @game.lobby?
      redirect_to truth_or_dare_lobby_path(@game)
    elsif @game.playing? || @game.paused?
      redirect_to truth_or_dare_play_path(@game)
    else
      render :finished
    end
  end

  def lobby
    @players = @game.truth_or_dare_players.includes(:user).by_position
  end

  def play
    @players = @game.truth_or_dare_players.includes(:user).by_position
    @current_player = @game.current_player
    @is_my_turn = @current_player&.user_id == current_user.id
  end

  def join
    create_or_find_guest! unless logged_in?

    if @game.has_player?(current_user)
      redirect_to truth_or_dare_path(@game)
      return
    end

    unless @game.joinable?
      redirect_to truth_or_dare_index_path, alert: 'No puedes unirte a esta partida'
      return
    end

    player = @game.add_player!(current_user)

    if player
      TruthOrDareChannel.broadcast_player_joined(@game, player)
      redirect_to truth_or_dare_lobby_path(@game)
    else
      redirect_to truth_or_dare_index_path, alert: 'No se pudo unir a la partida'
    end
  end

  def join_by_code
    code = params[:code]&.to_s&.upcase&.strip&.gsub(/[^A-Z0-9]/, '')
    game = TruthOrDareGame.find_by_code(code)

    if game
      redirect_to truth_or_dare_join_path(game)
    else
      redirect_to truth_or_dare_index_path, alert: "Codigo de partida invalido: #{code}"
    end
  end

  # Game Actions
  def start
    @game = TruthOrDareGame.find(params[:id])

    unless @game.host?(current_user)
      redirect_to truth_or_dare_lobby_path(@game), alert: 'Solo el anfitrion puede iniciar'
      return
    end

    if @game.start!
      TruthOrDareChannel.broadcast_game_started(@game)
      redirect_to truth_or_dare_play_path(@game)
    else
      redirect_to truth_or_dare_lobby_path(@game), alert: 'No se puede iniciar la partida'
    end
  end

  def choose_truth
    @game = TruthOrDareGame.find(params[:id])
    player = @game.player_for(current_user)

    unless player&.current_turn?
      render json: { error: 'No es tu turno' }, status: :forbidden
      return
    end

    card = @game.draw_truth_card!

    if card
      TruthOrDareChannel.broadcast_card_drawn(@game, player, 'truth', card)
      render json: { success: true, card: { id: card.id, content: card.content, intensity: card.intensity } }
    else
      render json: { error: 'No hay cartas disponibles' }, status: :unprocessable_entity
    end
  end

  def choose_dare
    @game = TruthOrDareGame.find(params[:id])
    player = @game.player_for(current_user)

    unless player&.current_turn?
      render json: { error: 'No es tu turno' }, status: :forbidden
      return
    end

    card = @game.draw_dare_card!

    if card
      TruthOrDareChannel.broadcast_card_drawn(@game, player, 'dare', card)
      render json: { success: true, card: { id: card.id, content: card.content, intensity: card.intensity } }
    else
      render json: { error: 'No hay cartas disponibles' }, status: :unprocessable_entity
    end
  end

  def complete_challenge
    @game = TruthOrDareGame.find(params[:id])
    player = @game.player_for(current_user)

    unless player&.current_turn?
      render json: { error: 'No es tu turno' }, status: :forbidden
      return
    end

    challenge_type = params[:challenge_type]

    if challenge_type == 'truth'
      player.record_truth!
    else
      player.record_dare!
    end

    @game.advance_turn!
    TruthOrDareChannel.broadcast_turn_completed(@game, player, challenge_type, false)

    render json: { success: true, next_player_id: @game.current_player.id }
  end

  def drink
    @game = TruthOrDareGame.find(params[:id])
    player = @game.player_for(current_user)

    unless player&.current_turn?
      render json: { error: 'No es tu turno' }, status: :forbidden
      return
    end

    player.record_drink!
    @game.advance_turn!
    TruthOrDareChannel.broadcast_turn_completed(@game, player, params[:challenge_type], true)

    render json: { success: true, next_player_id: @game.current_player.id }
  end

  def leave
    @game = TruthOrDareGame.find(params[:id])
    @game.remove_player!(current_user)
    TruthOrDareChannel.broadcast_player_left(@game, current_user)
    redirect_to truth_or_dare_index_path, notice: 'Has abandonado la partida'
  end

  def kick
    @game = TruthOrDareGame.find(params[:id])

    unless @game.host?(current_user)
      redirect_to truth_or_dare_lobby_path(@game), alert: 'Solo el anfitrion puede expulsar'
      return
    end

    player = @game.truth_or_dare_players.find(params[:player_id])
    user = player.user
    player.update!(status: :kicked)
    TruthOrDareChannel.broadcast_player_kicked(@game, player)
    player.destroy

    redirect_to truth_or_dare_lobby_path(@game), notice: "#{user.display_name} ha sido expulsado"
  end

  def update_settings
    @game = TruthOrDareGame.find(params[:id])

    unless @game.host?(current_user)
      redirect_to truth_or_dare_lobby_path(@game), alert: 'Solo el anfitrion puede cambiar la configuracion'
      return
    end

    if @game.update(settings_params)
      TruthOrDareChannel.broadcast_settings_updated(@game)
      redirect_to truth_or_dare_lobby_path(@game), notice: 'Configuracion actualizada'
    else
      redirect_to truth_or_dare_lobby_path(@game), alert: @game.errors.full_messages.join(', ')
    end
  end

  private

  def set_game
    @game = TruthOrDareGame.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to truth_or_dare_index_path, alert: 'Partida no encontrada'
  end

  def require_game_player
    unless @game.has_player?(current_user)
      redirect_to truth_or_dare_join_path(@game)
    end
  end

  def game_params
    params.require(:truth_or_dare_game).permit(:max_players, :intensity_level)
  end

  def settings_params
    params.require(:truth_or_dare_game).permit(:max_players, :intensity_level)
  end
end
