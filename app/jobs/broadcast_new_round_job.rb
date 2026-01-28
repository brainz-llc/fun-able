class BroadcastNewRoundJob < ApplicationJob
  queue_as :default

  def perform(game_id, broadcast_type)
    game = Game.find_by(id: game_id)
    return unless game

    case broadcast_type.to_sym
    when :game_ended
      GameChannel.broadcast_game_ended(game)
    when :new_round
      # Only broadcast if game is still playing and has a current round
      if game.playing? && game.current_round
        GameChannel.broadcast_new_round(game, game.current_round)
      end
    end
  end
end
