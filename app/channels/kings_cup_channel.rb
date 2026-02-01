class KingsCupChannel < ApplicationCable::Channel
  def subscribed
    @game = KingsCupGame.find_by(id: params[:game_id])
    return reject unless @game

    @player = @game.player_for(current_user)

    if @player && !@player.left? && !@player.kicked?
      stream_from broadcast_channel
      @player.mark_connected!
      broadcast_player_status_changed
    else
      reject
    end
  end

  def unsubscribed
    return unless @player

    if @game.playing?
      MarkKingsCupDisconnectedJob.set(wait: 3.seconds).perform_later(@player.id)
    else
      @player.mark_disconnected!
      broadcast_player_status_changed
    end
  end

  def ping
    transmit({ type: 'pong', timestamp: Time.current.to_i })
  end

  def request_state
    transmit({
      type: 'game_state',
      game: game_state,
      player: player_state
    })
  end

  # Class methods for broadcasting
  class << self
    def broadcast_to_game(game, data)
      ActionCable.server.broadcast("kings_cup_game_#{game.id}", data)
    end

    def broadcast_player_joined(game, player)
      broadcast_to_game(game, {
        type: 'player_joined',
        player: player_data(player),
        player_count: game.player_count
      })
    end

    def broadcast_player_left(game, player)
      broadcast_to_game(game, {
        type: 'player_left',
        player_id: player.id,
        user_id: player.user_id,
        player_count: game.player_count
      })
    end

    def broadcast_player_kicked(game, player)
      broadcast_to_game(game, {
        type: 'player_kicked',
        player_id: player.id,
        user_id: player.user_id
      })
    end

    def broadcast_game_started(game)
      broadcast_to_game(game, {
        type: 'game_started',
        cards_remaining: game.cards_remaining,
        current_player_id: game.current_player&.id
      })
    end

    def broadcast_card_drawn(game, card, player)
      broadcast_to_game(game, {
        type: 'card_drawn',
        card: {
          id: card.id,
          suit: card.suit,
          suit_symbol: card.suit_symbol,
          suit_color: card.suit_color,
          value: card.value,
          rule_name: card.rule_name,
          rule_description: card.rule_description,
          rule_icon: card.rule_icon
        },
        drawn_by: {
          id: player.id,
          name: player.display_name
        },
        game: {
          cards_remaining: game.cards_remaining,
          kings_drawn: game.kings_drawn,
          cup_fill_percentage: game.cup_fill_percentage,
          current_player_id: game.current_player&.id,
          finished: game.finished?
        }
      })
    end

    def broadcast_rule_added(game, rule)
      broadcast_to_game(game, {
        type: 'rule_added',
        rule: {
          id: rule.id,
          rule_text: rule.rule_text,
          creator_name: rule.creator_name
        }
      })
    end

    def broadcast_mate_set(game, player, mate)
      broadcast_to_game(game, {
        type: 'mate_set',
        player_id: player.id,
        player_name: player.display_name,
        mate_id: mate.id,
        mate_name: mate.display_name
      })
    end

    def broadcast_game_ended(game)
      broadcast_to_game(game, {
        type: 'game_ended',
        kings_drawn: game.kings_drawn,
        last_king_player: game.drawn_cards.find_by(value: 'K')&.drawn_by&.display_name
      })
    end

    private

    def player_data(player)
      {
        id: player.id,
        user_id: player.user_id,
        display_name: player.display_name,
        avatar_initials: player.avatar_initials,
        is_host: player.host?,
        is_question_master: player.is_question_master,
        mate_id: player.mate_player_id,
        connected: player.connected?
      }
    end
  end

  private

  def broadcast_channel
    "kings_cup_game_#{@game.id}"
  end

  def broadcast_player_status_changed
    KingsCupChannel.broadcast_to_game(@game, {
      type: 'player_status_changed',
      player_id: @player.id,
      connected: @player.connected?
    })
  end

  def game_state
    {
      id: @game.id,
      code: @game.code,
      status: @game.status,
      host_id: @game.host_id,
      cards_remaining: @game.cards_remaining,
      kings_drawn: @game.kings_drawn,
      cup_fill_percentage: @game.cup_fill_percentage,
      current_player_id: @game.current_player&.id,
      players: @game.kings_cup_players.includes(:user).map { |p| self.class.send(:player_data, p) },
      active_rules: @game.active_rules.map { |r| { id: r.id, rule_text: r.rule_text, creator_name: r.creator_name } },
      recent_cards: @game.drawn_cards.limit(5).map do |c|
        {
          id: c.id,
          suit: c.suit,
          suit_symbol: c.suit_symbol,
          value: c.value,
          drawn_by: c.drawn_by&.display_name
        }
      end
    }
  end

  def player_state
    return nil unless @player

    {
      id: @player.id,
      is_host: @player.host?,
      is_current_turn: @player.current_turn?,
      is_question_master: @player.is_question_master,
      mate_id: @player.mate_player_id
    }
  end
end
