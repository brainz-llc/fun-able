class NeverHaveIEverMarkDisconnectedJob < ApplicationJob
  queue_as :default

  def perform(player_id)
    player = NeverHaveIEverPlayer.find_by(id: player_id)
    return unless player
    return if player.connected? # Player reconnected

    player.mark_disconnected!
    NeverHaveIEverChannel.broadcast_to_game(player.game, {
      type: 'player_status_changed',
      player_id: player.id,
      connected: false
    })
  end
end
