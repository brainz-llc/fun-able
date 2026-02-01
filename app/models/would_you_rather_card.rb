class WouldYouRatherCard < ApplicationRecord
  # Validations
  validates :option_a, presence: true
  validates :option_b, presence: true
  validates :category, presence: true

  # Scopes
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :shuffled, -> { order(Arel.sql('RANDOM()')) }
  scope :popular, -> { order(times_played: :desc) }

  # Categories
  CATEGORIES = %w[funny spicy philosophical embarrassing lifestyle hypothetical].freeze

  # Instance methods
  def record_play!(winning_choice)
    increment!(:times_played)
    if winning_choice == 'a'
      increment!(:option_a_wins)
    elsif winning_choice == 'b'
      increment!(:option_b_wins)
    end
  end

  def option_a_percentage
    return 50 if times_played.zero?
    ((option_a_wins.to_f / times_played) * 100).round
  end

  def option_b_percentage
    return 50 if times_played.zero?
    ((option_b_wins.to_f / times_played) * 100).round
  end
end
