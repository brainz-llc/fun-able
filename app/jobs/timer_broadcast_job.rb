class TimerBroadcastJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    game = Game.find_by(id: game_id)
    return unless game&.playing?

    round = game.current_round
    return unless round&.active?
    return unless round.timer_expires_at

    GameChannel.broadcast_timer_update(game, round)

    # Schedule next update if timer still has time
    if round.timer_remaining > 0
      TimerBroadcastJob.set(wait: 5.seconds).perform_later(game_id)
    end
  end
end
