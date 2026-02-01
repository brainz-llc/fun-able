class TruthOrDareChannel < ApplicationCable::Channel
  def subscribed
    @game = TruthOrDareGame.find_by(id: params[:game_id])
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
      # Don't immediately mark as disconnected - allow for page refreshes
      @player.mark_disconnected!
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
      ActionCable.server.broadcast("truth_or_dare_game_#{game.id}", data)
    end

    def broadcast_player_joined(game, player)
      broadcast_to_game(game, {
        type: 'player_joined',
        player: player_data(player),
        player_count: game.player_count
      })
    end

    def broadcast_player_left(game, user)
      broadcast_to_game(game, {
        type: 'player_left',
        user_id: user.id,
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

    def broadcast_settings_updated(game)
      broadcast_to_game(game, {
        type: 'settings_updated',
        settings: {
          max_players: game.max_players,
          intensity_level: game.intensity_level
        }
      })
    end

    def broadcast_game_started(game)
      broadcast_to_game(game, {
        type: 'game_started',
        current_player_id: game.current_player.id,
        current_player_name: game.current_player.display_name
      })
    end

    def broadcast_card_drawn(game, player, card_type, card)
      broadcast_to_game(game, {
        type: 'card_drawn',
        player_id: player.id,
        player_name: player.display_name,
        card_type: card_type,
        card: {
          id: card.id,
          content: card.content,
          intensity: card.intensity
        }
      })
    end

    def broadcast_turn_completed(game, player, challenge_type, drank)
      broadcast_to_game(game, {
        type: 'turn_completed',
        player_id: player.id,
        player_name: player.display_name,
        challenge_type: challenge_type,
        drank: drank,
        next_player_id: game.current_player.id,
        next_player_name: game.current_player.display_name,
        leaderboard: leaderboard_data(game)
      })
    end

    def broadcast_game_ended(game)
      broadcast_to_game(game, {
        type: 'game_ended',
        final_leaderboard: leaderboard_data(game)
      })
    end

    private

    def player_data(player)
      {
        id: player.id,
        user_id: player.user_id,
        display_name: player.display_name,
        avatar_initials: player.avatar_initials,
        drinks_taken: player.drinks_taken,
        truths_completed: player.truths_completed,
        dares_completed: player.dares_completed,
        is_host: player.host?,
        connected: player.connected?
      }
    end

    def leaderboard_data(game)
      game.leaderboard.map do |player|
        {
          id: player.id,
          display_name: player.display_name,
          drinks_taken: player.drinks_taken,
          truths_completed: player.truths_completed,
          dares_completed: player.dares_completed
        }
      end
    end
  end

  private

  def broadcast_channel
    "truth_or_dare_game_#{@game.id}"
  end

  def broadcast_player_status_changed
    TruthOrDareChannel.broadcast_to_game(@game, {
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
      max_players: @game.max_players,
      intensity_level: @game.intensity_level,
      current_player_id: @game.current_player&.id,
      players: @game.truth_or_dare_players.includes(:user).map { |p| self.class.send(:player_data, p) }
    }
  end

  def player_state
    return nil unless @player

    {
      id: @player.id,
      is_current_turn: @player.current_turn?,
      drinks_taken: @player.drinks_taken,
      truths_completed: @player.truths_completed,
      dares_completed: @player.dares_completed
    }
  end
end
