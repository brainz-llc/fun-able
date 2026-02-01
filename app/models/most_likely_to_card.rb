class MostLikelyToCard < ApplicationRecord
  # Validations
  validates :content, presence: true
  validates :category, presence: true

  # Scopes
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :shuffled, -> { order(Arel.sql('RANDOM()')) }
  scope :popular, -> { order(times_played: :desc) }

  # Categories
  CATEGORIES = %w[party embarrassing success habits relationships funny spicy].freeze

  # Instance methods
  def record_play!
    increment!(:times_played)
  end
end
