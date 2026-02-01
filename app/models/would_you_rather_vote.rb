class WouldYouRatherVote < ApplicationRecord
  # Associations
  belongs_to :would_you_rather_game
  belongs_to :would_you_rather_player
  belongs_to :would_you_rather_card

  # Validations
  validates :round_number, presence: true
  validates :choice, presence: true, inclusion: { in: %w[a b] }
  validates :would_you_rather_player_id, uniqueness: { scope: [:would_you_rather_game_id, :round_number] }

  # Scopes
  scope :for_round, ->(round) { where(round_number: round) }
  scope :option_a, -> { where(choice: 'a') }
  scope :option_b, -> { where(choice: 'b') }
end
