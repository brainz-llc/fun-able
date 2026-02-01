class MarkMostLikelyToDisconnectedJob < ApplicationJob
  queue_as :default

  def perform(player_id)
    player = MostLikelyToPlayer.find_by(id: player_id)
    return unless player
    return if player.connected? # Already reconnected

    player.mark_disconnected!

    MostLikelyToChannel.broadcast_to_game(player.most_likely_to_game, {
      type: 'player_status_changed',
      player_id: player.id,
      connected: false
    })
  end
end
