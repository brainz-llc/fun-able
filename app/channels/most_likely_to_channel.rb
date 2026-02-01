class MostLikelyToChannel < ApplicationCable::Channel
  def subscribed
    @game = MostLikelyToGame.find_by(id: params[:game_id])
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
      MarkMostLikelyToDisconnectedJob.set(wait: 3.seconds).perform_later(@player.id)
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
      ActionCable.server.broadcast("most_likely_to_game_#{game.id}", data)
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

    def broadcast_game_started(game)
      broadcast_to_game(game, {
        type: 'game_started',
        round: game.current_round,
        total_rounds: game.total_rounds,
        card: card_data(game.current_card),
        phase: game.phase
      })
    end

    def broadcast_vote_received(game, voter)
      broadcast_to_game(game, {
        type: 'vote_received',
        voter_id: voter.id,
        votes_count: game.votes_for_round.count,
        expected_count: game.active_players.count,
        all_voted: game.all_voted?
      })
    end

    def broadcast_reveal_results(game)
      winners = game.winners
      vote_counts = game.vote_counts

      broadcast_to_game(game, {
        type: 'reveal_results',
        round: game.current_round,
        winners: winners.map { |w| player_data(w) },
        vote_counts: vote_counts.transform_keys(&:to_s),
        all_players: game.active_players.map { |p|
          player_data(p).merge(votes_received: vote_counts[p.id] || 0)
        }
      })
    end

    def broadcast_new_round(game)
      broadcast_to_game(game, {
        type: 'new_round',
        round: game.current_round,
        total_rounds: game.total_rounds,
        card: card_data(game.current_card),
        phase: game.phase,
        leaderboard: leaderboard_data(game)
      })
    end

    def broadcast_game_ended(game)
      broadcast_to_game(game, {
        type: 'game_ended',
        final_leaderboard: leaderboard_data(game),
        winner: game.leaderboard.first ? player_data(game.leaderboard.first) : nil
      })
    end

    private

    def player_data(player)
      {
        id: player.id,
        user_id: player.user_id,
        display_name: player.display_name,
        avatar_initials: player.avatar_initials,
        drinks: player.drinks,
        is_host: player.host?,
        connected: player.connected?,
        has_voted: player.has_voted_this_round?
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
          drinks: player.drinks
        }
      end
    end
  end

  private

  def broadcast_channel
    "most_likely_to_game_#{@game.id}"
  end

  def broadcast_player_status_changed
    MostLikelyToChannel.broadcast_to_game(@game, {
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
      phase: @game.phase,
      current_round: @game.current_round,
      total_rounds: @game.total_rounds,
      current_card: @game.current_card ? self.class.send(:card_data, @game.current_card) : nil,
      players: @game.most_likely_to_players.includes(:user).map { |p| self.class.send(:player_data, p) }
    }
  end

  def player_state
    return nil unless @player

    {
      id: @player.id,
      has_voted: @player.has_voted_this_round?,
      drinks: @player.drinks
    }
  end
end
