class NeverHaveIEverCard < ApplicationRecord
  # Enums
  enum :category, { tame: 0, spicy: 1, extreme: 2 }

  # Validations
  validates :content, presence: true
  validates :category, presence: true

  # Scopes
  scope :shuffled, -> { order(Arel.sql('RANDOM()')) }
  scope :by_category, ->(cat) { where(category: cat) }
end
