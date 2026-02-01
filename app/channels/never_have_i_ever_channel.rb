class NeverHaveIEverChannel < ApplicationCable::Channel
  def subscribed
    @game = NeverHaveIEverGame.find_by(id: params[:game_id])
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
      NeverHaveIEverMarkDisconnectedJob.set(wait: 3.seconds).perform_later(@player.id)
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
      ActionCable.server.broadcast("never_have_i_ever_game_#{game.id}", data)
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

    def broadcast_settings_updated(game)
      broadcast_to_game(game, {
        type: 'settings_updated',
        settings: {
          category: game.category,
          starting_points: game.starting_points,
          max_players: game.max_players
        }
      })
    end

    def broadcast_game_started(game)
      broadcast_to_game(game, {
        type: 'game_started',
        current_card: card_data(game.current_card),
        current_reader_id: game.current_reader&.id,
        leaderboard: leaderboard_data(game)
      })
    end

    def broadcast_new_card(game)
      broadcast_to_game(game, {
        type: 'new_card',
        current_card: card_data(game.current_card),
        current_reader_id: game.current_reader&.id,
        leaderboard: leaderboard_data(game)
      })
    end

    def broadcast_player_drank(game, player)
      broadcast_to_game(game, {
        type: 'player_drank',
        player_id: player.id,
        player_name: player.display_name,
        new_points: player.points,
        leaderboard: leaderboard_data(game)
      })
    end

    def broadcast_player_eliminated(game, player)
      broadcast_to_game(game, {
        type: 'player_eliminated',
        player_id: player.id,
        player_name: player.display_name
      })
    end

    def broadcast_game_ended(game)
      winner = game.winner

      broadcast_to_game(game, {
        type: 'game_ended',
        winner_id: winner&.id,
        winner_name: winner&.display_name,
        winner_points: winner&.points,
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
        points: player.points,
        is_host: player.host?,
        is_reader: player.current_reader?,
        connected: player.connected?,
        drank_this_round: player.drank_this_round?
      }
    end

    def card_data(card)
      return nil unless card
      {
        id: card.id,
        content: card.content,
        category: card.category
      }
    end

    def leaderboard_data(game)
      game.leaderboard.map do |player|
        {
          id: player.id,
          display_name: player.display_name,
          avatar_initials: player.avatar_initials,
          points: player.points,
          is_reader: player.current_reader?,
          drank_this_round: player.drank_this_round?,
          eliminated: player.eliminated?
        }
      end
    end
  end

  private

  def broadcast_channel
    "never_have_i_ever_game_#{@game.id}"
  end

  def broadcast_player_status_changed
    NeverHaveIEverChannel.broadcast_to_game(@game, {
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
      category: @game.category,
      starting_points: @game.starting_points,
      current_card: @game.current_card ? self.class.send(:card_data, @game.current_card) : nil,
      current_reader_id: @game.current_reader&.id,
      players: @game.never_have_i_ever_players.includes(:user).map { |p| self.class.send(:player_data, p) }
    }
  end

  def player_state
    return nil unless @player

    {
      id: @player.id,
      points: @player.points,
      is_reader: @player.current_reader?,
      drank_this_round: @player.drank_this_round?
    }
  end
end
