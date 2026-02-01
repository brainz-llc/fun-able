class MostLikelyToVote < ApplicationRecord
  # Associations
  belongs_to :most_likely_to_game
  belongs_to :voter, class_name: 'MostLikelyToPlayer'
  belongs_to :voted_for, class_name: 'MostLikelyToPlayer'

  # Validations
  validates :round_number, presence: true
  validates :voter_id, uniqueness: { scope: [:most_likely_to_game_id, :round_number], message: 'ya voto esta ronda' }

  # Scopes
  scope :for_round, ->(round) { where(round_number: round) }
end
