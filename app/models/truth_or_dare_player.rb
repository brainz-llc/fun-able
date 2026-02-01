class TruthOrDarePlayer < ApplicationRecord
  # Associations
  belongs_to :truth_or_dare_game
  belongs_to :user

  # Enums
  enum :status, { active: 0, disconnected: 1, left: 2, kicked: 3 }

  # Validations
  validates :user_id, uniqueness: { scope: :truth_or_dare_game_id }

  # Scopes
  scope :by_position, -> { order(:position) }
  scope :connected, -> { where(status: :active) }

  # Delegations
  delegate :display_name, :avatar_initials, to: :user

  # Instance methods
  def mark_connected!
    update!(status: :active, connected_at: Time.current, disconnected_at: nil)
  end

  def mark_disconnected!
    update!(status: :disconnected, disconnected_at: Time.current)
  end

  def connected?
    active?
  end

  def host?
    truth_or_dare_game.host_id == user_id
  end

  def current_turn?
    truth_or_dare_game.current_player&.id == id
  end

  def record_truth!
    increment!(:truths_completed)
  end

  def record_dare!
    increment!(:dares_completed)
  end

  def record_drink!
    increment!(:drinks_taken)
  end
end
