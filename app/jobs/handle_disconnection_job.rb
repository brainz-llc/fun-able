class HandleDisconnectionJob < ApplicationJob
  queue_as :default

  def perform(game_player_id)
    player = GamePlayer.find_by(id: game_player_id)
    return unless player
    return unless player.game&.playing?

    # If player reconnected, skip entirely
    return if player.connected?

    # If player already left or was kicked, skip
    return if player.left? || player.kicked?

    # Only proceed if player has been disconnected for a significant time
    # This prevents race conditions with brief disconnections
    return unless player.disconnected?
    return unless player.disconnected_at
    return unless player.disconnected_at < 25.seconds.ago

    Rails.logger.info("HandleDisconnectionJob: Removing player #{player.id} (#{player.display_name}) - disconnected since #{player.disconnected_at}")

    service = GameService.new(player.game)
    service.player_disconnected!(player)
  end
end
