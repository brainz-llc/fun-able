class HandleDisconnectionJob < ApplicationJob
  queue_as :default

  def perform(game_player_id)
    player = GamePlayer.find_by(id: game_player_id)
    return unless player
    return if player.connected?
    return unless player.game.playing?

    # Check if still disconnected after grace period
    if player.disconnected_at && player.disconnected_at < 25.seconds.ago
      service = GameService.new(player.game)
      service.player_disconnected!(player)
    end
  rescue => e
    Rails.logger.error("HandleDisconnectionJob failed: #{e.message}")
  end
end
