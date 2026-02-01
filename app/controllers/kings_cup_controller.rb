class KingsCupController < ApplicationController
  before_action :set_game, only: [:show, :lobby, :join, :start, :draw_card, :add_rule, :set_mate, :leave, :kick]
  before_action :require_game_player, only: [:lobby, :draw_card, :add_rule, :set_mate, :leave]
  before_action :require_game_host, only: [:start, :kick]
  before_action :require_playing, only: [:draw_card, :add_rule, :set_mate]

  def index
    # Landing page for King's Cup
  end

  def new
    create_or_find_guest! unless logged_in?
    @game = KingsCupGame.new(max_players: 10)
  end

  def create
    create_or_find_guest! unless logged_in?

    @game = KingsCupGame.new(game_params)
    @game.host = current_user

    if @game.save
      @game.add_player!(current_user)
      redirect_to kings_cup_lobby_path(@game)
    else
      flash.now[:alert] = @game.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def show
    if @game.lobby?
      redirect_to kings_cup_lobby_path(@game)
    elsif @game.playing? || @game.paused?
      render :play
    else
      render :finished
    end
  end

  def lobby
    @players = @game.kings_cup_players.includes(:user).by_position
  end

  def join
    create_or_find_guest! unless logged_in?

    if @game.has_player?(current_user)
      redirect_to kings_cup_path(@game)
      return
    end

    unless @game.joinable?
      redirect_to kings_cup_path, alert: 'No puedes unirte a esta partida'
      return
    end

    player = @game.add_player!(current_user)

    if player
      KingsCupChannel.broadcast_player_joined(@game, player)
      redirect_to kings_cup_lobby_path(@game)
    else
      redirect_to kings_cup_path, alert: 'No se pudo unir a la partida'
    end
  end

  def join_by_code
    raw_code = params[:code]
    code = raw_code&.to_s&.upcase&.strip&.gsub(/[^A-Z0-9]/, '')

    game = KingsCupGame.find_by_code(code)

    if game
      redirect_to kings_cup_join_path(game)
    else
      redirect_to kings_cup_path, alert: "Codigo de partida invalido: #{code}"
    end
  end

  def start
    unless @game.can_start?
      redirect_to kings_cup_lobby_path(@game), alert: 'No se puede iniciar la partida'
      return
    end

    if @game.start!
      KingsCupChannel.broadcast_game_started(@game)
      redirect_to kings_cup_path(@game)
    else
      redirect_to kings_cup_lobby_path(@game), alert: 'Error al iniciar la partida'
    end
  end

  def draw_card
    unless current_kings_cup_player.current_turn?
      render json: { error: 'No es tu turno' }, status: :forbidden
      return
    end

    card = @game.draw_card!(current_kings_cup_player)

    if card
      KingsCupChannel.broadcast_card_drawn(@game, card, current_kings_cup_player)

      render json: {
        success: true,
        card: card_json(card),
        game: game_state_json
      }
    else
      render json: { error: 'No se pudo sacar carta' }, status: :unprocessable_entity
    end
  end

  def add_rule
    rule = @game.kings_cup_rules.create(
      rule_text: params[:rule_text],
      created_by: current_kings_cup_player
    )

    if rule.persisted?
      KingsCupChannel.broadcast_rule_added(@game, rule)
      render json: { success: true, rule: rule_json(rule) }
    else
      render json: { error: rule.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def set_mate
    target_player = @game.kings_cup_players.find_by(id: params[:player_id])

    unless target_player && target_player.id != current_kings_cup_player.id
      render json: { error: 'Jugador invalido' }, status: :unprocessable_entity
      return
    end

    current_kings_cup_player.set_mate!(target_player)
    KingsCupChannel.broadcast_mate_set(@game, current_kings_cup_player, target_player)

    render json: { success: true }
  end

  def leave
    @game.remove_player!(current_user)
    KingsCupChannel.broadcast_player_left(@game, current_kings_cup_player)
    redirect_to kings_cup_path, notice: 'Has abandonado la partida'
  end

  def kick
    player = @game.kings_cup_players.find_by(id: params[:player_id])

    if player && player.user_id != current_user.id
      player.update!(status: :kicked)
      KingsCupChannel.broadcast_player_kicked(@game, player)
      render json: { success: true }
    else
      render json: { error: 'No se puede expulsar a este jugador' }, status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = KingsCupGame.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to kings_cup_path, alert: 'Partida no encontrada'
  end

  def current_kings_cup_player
    @current_kings_cup_player ||= @game.player_for(current_user)
  end
  helper_method :current_kings_cup_player

  def require_game_player
    unless current_kings_cup_player
      redirect_to kings_cup_path, alert: 'No eres parte de esta partida'
    end
  end

  def require_game_host
    unless @game.host?(current_user)
      redirect_to kings_cup_path(@game), alert: 'Solo el anfitrion puede hacer esto'
    end
  end

  def require_playing
    unless @game.playing?
      redirect_to kings_cup_path(@game), alert: 'La partida no esta activa'
    end
  end

  def game_params
    params.require(:kings_cup_game).permit(:max_players)
  end

  def card_json(card)
    {
      id: card.id,
      suit: card.suit,
      suit_symbol: card.suit_symbol,
      suit_color: card.suit_color,
      value: card.value,
      rule_name: card.rule_name,
      rule_description: card.rule_description,
      rule_icon: card.rule_icon,
      drawn_by: card.drawn_by&.display_name
    }
  end

  def game_state_json
    {
      cards_remaining: @game.cards_remaining,
      kings_drawn: @game.kings_drawn,
      cup_fill_percentage: @game.cup_fill_percentage,
      current_player_id: @game.current_player&.id,
      status: @game.status,
      finished: @game.finished?
    }
  end

  def rule_json(rule)
    {
      id: rule.id,
      rule_text: rule.rule_text,
      creator_name: rule.creator_name,
      created_at: rule.created_at.iso8601
    }
  end
end
