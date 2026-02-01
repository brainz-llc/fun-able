class MostLikelyToPlayer < ApplicationRecord
  # Associations
  belongs_to :most_likely_to_game
  belongs_to :user
  has_many :votes_cast, class_name: 'MostLikelyToVote', foreign_key: :voter_id, dependent: :destroy
  has_many :votes_received, class_name: 'MostLikelyToVote', foreign_key: :voted_for_id, dependent: :destroy

  # Enums
  enum :status, { active: 0, disconnected: 1, left: 2, kicked: 3 }

  # Validations
  validates :user_id, uniqueness: { scope: :most_likely_to_game_id }

  # Scopes
  scope :by_position, -> { order(:position) }
  scope :by_drinks, -> { order(drinks: :desc) }
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
    most_likely_to_game.host_id == user_id
  end

  def drink!
    increment!(:drinks)
  end

  def has_voted_this_round?
    votes_cast.exists?(round_number: most_likely_to_game.current_round)
  end

  def vote_for!(target_player)
    return false if has_voted_this_round?

    MostLikelyToVote.create!(
      most_likely_to_game: most_likely_to_game,
      voter: self,
      voted_for: target_player,
      round_number: most_likely_to_game.current_round
    )
    true
  end

  def votes_received_this_round
    votes_received.where(round_number: most_likely_to_game.current_round).count
  end
end
