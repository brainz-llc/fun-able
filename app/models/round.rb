class Round < ApplicationRecord
  # Associations
  belongs_to :game
  belongs_to :judge, class_name: 'GamePlayer'
  belongs_to :black_card, class_name: 'Card'
  belongs_to :winner, class_name: 'GamePlayer', optional: true
  has_many :card_submissions, dependent: :destroy

  # Enums
  enum :phase, { submitting: 0, judging: 1, revealing: 2, complete: 3 }

  # Validations
  validates :round_number, presence: true, uniqueness: { scope: :game_id }

  # Scopes
  scope :active, -> { where.not(phase: :complete) }
  scope :by_number, -> { order(:round_number) }

  # Instance methods
  def active?
    !complete?
  end

  def timer_remaining
    return 0 unless timer_expires_at
    [(timer_expires_at - Time.current).to_i, 0].max
  end

  def timer_expired?
    timer_expires_at.present? && timer_expires_at <= Time.current
  end

  def expected_submissions_count
    # All players except the judge
    game.active_players.where.not(id: judge_id).count
  end

  def submissions_count
    card_submissions.count
  end

  def all_submitted?
    submissions_count >= expected_submissions_count
  end

  def can_advance_to_judging?
    submitting? && all_submitted?
  end

  def can_advance_to_revealing?
    judging?
  end

  def advance_to_judging!
    return false unless can_advance_to_judging?

    # Shuffle submission order for judging
    card_submissions.shuffle.each_with_index do |submission, index|
      submission.update!(reveal_order: index + 1)
    end

    update!(
      phase: :judging,
      timer_expires_at: game.turn_timer.seconds.from_now
    )
  end

  def advance_to_revealing!
    return false unless can_advance_to_revealing?
    update!(phase: :revealing)
  end

  def select_winner!(submission)
    return false unless judging? || revealing?

    transaction do
      submission.mark_winner!
      submission.player.award_point!

      update!(
        winner: submission.player,
        phase: :complete,
        timer_expires_at: nil
      )

      check_game_winner!
    end

    true
  end

  def submission_by(player)
    card_submissions.find_by(player: player)
  end

  def submissions_for_display
    card_submissions.includes(:submission_cards, :player).order(:reveal_order)
  end

  def pick_count
    black_card.pick_count
  end

  private

  def check_game_winner!
    winning_player = game.game_players.find_by('score >= ?', game.points_to_win)

    if winning_player
      game.finish!
      winning_player.user.increment_stat!(:games_won)
      game.players.each { |p| p.increment_stat!(:games_played) }
    else
      game.start_new_round!
    end
  end
end
