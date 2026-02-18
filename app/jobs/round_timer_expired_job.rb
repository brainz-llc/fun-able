class RoundTimerExpiredJob < ApplicationJob
  queue_as :default

  def perform(game_id, round_id)
    game = Game.find_by(id: game_id)
    return unless game&.playing?

    round = game.rounds.find_by(id: round_id)
    return unless round
    return if round.complete?
    return unless round.timer_expired?

    service = GameService.new(game)
    service.handle_timer_expired!
  end
end
