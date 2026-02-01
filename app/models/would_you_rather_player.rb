class WouldYouRatherPlayer < ApplicationRecord
  # Associations
  belongs_to :would_you_rather_game
  belongs_to :user
  has_many :would_you_rather_votes, dependent: :destroy

  # Enums
  enum :status, { active: 0, disconnected: 1, left: 2 }

  # Validations
  validates :user_id, uniqueness: { scope: :would_you_rather_game_id }

  # Scopes
  scope :connected, -> { where(status: [:active]) }
  scope :by_drinks, -> { order(drinks_taken: :desc) }

  # Delegate
  delegate :display_name, :avatar_initials, to: :user

  # Instance methods
  def drink!
    increment!(:drinks_taken)
    increment!(:times_in_minority)
    update!(current_streak: 0)
  end

  def increment_streak!
    new_streak = current_streak + 1
    update!(
      current_streak: new_streak,
      max_streak: [max_streak, new_streak].max
    )
  end

  def voted_for_round?(round_number)
    would_you_rather_votes.exists?(round_number: round_number)
  end

  def vote_for_round(round_number)
    would_you_rather_votes.find_by(round_number: round_number)
  end

  def mark_connected!
    update!(status: :active, connected_at: Time.current)
  end

  def mark_disconnected!
    update!(status: :disconnected)
  end

  def host?
    is_host
  end

  def connected?
    active?
  end
end
