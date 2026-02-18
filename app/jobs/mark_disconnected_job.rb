class MarkDisconnectedJob < ApplicationJob
  queue_as :default

  def perform(game_player_id)
    player = GamePlayer.find_by(id: game_player_id)
    return unless player
    return unless player.game&.playing?

    # If player is currently connected (reconnected during the delay), skip entirely
    # This handles brief disconnections during Turbo page transitions
    if player.connected?
      Rails.logger.debug("Player #{player.id} is connected, skipping disconnect mark")
      return
    end

    # If player status is :left or :kicked, they're already gone
    return if player.left? || player.kicked?

    # If player is already marked disconnected, don't broadcast again or schedule another job
    # This prevents duplicate events when multiple jobs run for the same player
    if player.disconnected?
      Rails.logger.debug("Player #{player.id} already disconnected, skipping")
      return
    end

    # Mark as disconnected and broadcast
    player.mark_disconnected!
    GameChannel.broadcast_to_game(player.game, {
      type: 'player_status_changed',
      player_id: player.id,
      connected: false
    })

    # Schedule the removal check (only runs once since we return early if already disconnected)
    HandleDisconnectionJob.set(wait: 30.seconds).perform_later(player.id)
  end
end
