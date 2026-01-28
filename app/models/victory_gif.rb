class VictoryGif < ApplicationRecord
  # Enums
  enum :category, { round_win: 0, game_win: 1 }

  # Validations
  validates :url, presence: true

  # Scopes
  scope :for_round_win, -> { round_win }
  scope :for_game_win, -> { game_win }
  scope :random_one, -> { order('RANDOM()').first }

  # Class methods
  def self.random_for(category)
    where(category: category).random_one
  end

  def self.random_round_win
    for_round_win.random_one
  end

  def self.random_game_win
    for_game_win.random_one
  end
end
