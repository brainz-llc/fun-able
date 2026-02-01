class TruthCard < ApplicationRecord
  # Enums
  enum :intensity, { mild: 0, medium: 1, spicy: 2 }

  # Validations
  validates :content, presence: true

  # Scopes
  scope :by_intensity, ->(level) { where(intensity: level) }
  scope :up_to_intensity, ->(level) { where(intensity: ..level) }
  scope :shuffled, -> { order('RANDOM()') }
  scope :not_in, ->(ids) { where.not(id: ids) if ids.present? }

  # Class methods
  def self.random_for_intensity(intensity_level, exclude_ids = [])
    up_to_intensity(intensity_level)
      .not_in(exclude_ids)
      .shuffled
      .first
  end
end
