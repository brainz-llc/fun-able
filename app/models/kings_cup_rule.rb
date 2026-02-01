class KingsCupRule < ApplicationRecord
  # Associations
  belongs_to :kings_cup_game
  belongs_to :created_by, class_name: 'KingsCupPlayer', optional: true

  # Validations
  validates :rule_text, presence: true, length: { maximum: 200 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :recent_first, -> { order(created_at: :desc) }

  # Methods
  def deactivate!
    update!(active: false)
  end

  def creator_name
    created_by&.display_name || 'Sistema'
  end
end
