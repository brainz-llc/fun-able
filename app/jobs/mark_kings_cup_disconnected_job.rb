class MarkKingsCupDisconnectedJob < ApplicationJob
  queue_as :default

  def perform(player_id)
    player = KingsCupPlayer.find_by(id: player_id)
    return unless player
    return if player.left? || player.kicked?

    # Only mark as disconnected if they haven't reconnected
    # Check if they're still connected by verifying their connected_at hasn't been updated
    if player.active? && player.connected_at.present?
      player.mark_disconnected!

      KingsCupChannel.broadcast_to_game(player.kings_cup_game, {
        type: 'player_status_changed',
        player_id: player.id,
        connected: false
      })
    end
  end
end
