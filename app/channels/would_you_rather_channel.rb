class WouldYouRatherChannel < ApplicationCable::Channel
  def subscribed
    @game = WouldYouRatherGame.find_by(id: params[:game_id])
    return reject unless @game

    @player = @game.player_for(current_user)

    if @player && !@player.left?
      stream_from broadcast_channel
      @player.mark_connected!
      broadcast_player_status_changed
    else
      reject
    end
  end

  def unsubscribed
    return unless @player

    @player.mark_disconnected!
    broadcast_player_status_changed
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
      ActionCable.server.broadcast("would_you_rather_game_#{game.id}", data)
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
        card: card_data(game.current_card),
        voting_ends_at: game.voting_ends_at&.iso8601
      })
    end

    def broadcast_new_round(game)
      broadcast_to_game(game, {
        type: 'new_round',
        round: game.current_round,
        max_rounds: game.max_rounds,
        card: card_data(game.current_card),
        voting_ends_at: game.voting_ends_at&.iso8601,
        leaderboard: leaderboard_data(game)
      })
    end

    def broadcast_vote_submitted(game)
      broadcast_to_game(game, {
        type: 'vote_submitted',
        votes_count: game.votes_for_current_round.count,
        total_players: game.active_players.count,
        all_voted: game.all_voted?
      })
    end

    def broadcast_votes_revealed(game, results)
      broadcast_to_game(game, {
        type: 'votes_revealed',
        option_a_votes: results[:option_a_votes],
        option_b_votes: results[:option_b_votes],
        option_a_percentage: calculate_percentage(results[:option_a_votes], results[:option_b_votes]),
        option_b_percentage: calculate_percentage(results[:option_b_votes], results[:option_a_votes]),
        minority_choice: results[:minority_choice],
        minority_player_ids: results[:minority_player_ids],
        is_tie: results[:minority_choice].nil?,
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
        current_streak: player.current_streak,
        max_streak: player.max_streak,
        is_host: player.host?,
        connected: player.connected?
      }
    end

    def card_data(card)
      return nil unless card
      {
        id: card.id,
        option_a: card.option_a,
        option_b: card.option_b,
        category: card.category,
        global_option_a_percentage: card.option_a_percentage,
        global_option_b_percentage: card.option_b_percentage
      }
    end

    def leaderboard_data(game)
      game.leaderboard.map do |player|
        {
          id: player.id,
          display_name: player.display_name,
          drinks_taken: player.drinks_taken,
          current_streak: player.current_streak,
          max_streak: player.max_streak
        }
      end
    end

    def calculate_percentage(votes, other_votes)
      total = votes + other_votes
      return 50 if total.zero?
      ((votes.to_f / total) * 100).round
    end
  end

  private

  def broadcast_channel
    "would_you_rather_game_#{@game.id}"
  end

  def broadcast_player_status_changed
    WouldYouRatherChannel.broadcast_to_game(@game, {
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
      current_round: @game.current_round,
      max_rounds: @game.max_rounds,
      phase: @game.phase,
      current_card: self.class.send(:card_data, @game.current_card),
      voting_ends_at: @game.voting_ends_at&.iso8601,
      players: @game.would_you_rather_players.includes(:user).map { |p| self.class.send(:player_data, p) }
    }
  end

  def player_state
    return nil unless @player

    {
      id: @player.id,
      has_voted: @player.voted_for_round?(@game.current_round),
      drinks_taken: @player.drinks_taken,
      current_streak: @player.current_streak
    }
  end
end
