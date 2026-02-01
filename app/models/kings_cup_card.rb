class KingsCupCard < ApplicationRecord
  # Associations
  belongs_to :kings_cup_game
  belongs_to :drawn_by, class_name: 'KingsCupPlayer', optional: true

  # Validations
  validates :suit, presence: true, inclusion: { in: KingsCupGame::SUITS }
  validates :value, presence: true, inclusion: { in: KingsCupGame::VALUES }
  validates :suit, uniqueness: { scope: [:kings_cup_game_id, :value] }

  # Scopes
  scope :available, -> { where(drawn: false) }
  scope :drawn, -> { where(drawn: true) }
  scope :by_draw_order, -> { order(drawn_at: :desc) }

  # Methods
  def suit_symbol
    KingsCupGame::SUIT_SYMBOLS[suit]
  end

  def suit_color
    KingsCupGame::SUIT_COLORS[suit]
  end

  def red?
    suit_color == 'red'
  end

  def rule
    KingsCupGame::CARD_RULES[value]
  end

  def rule_name
    rule[:name]
  end

  def rule_description
    rule[:description]
  end

  def rule_icon
    rule[:icon]
  end

  def display_value
    value
  end

  def full_name
    "#{display_value}#{suit_symbol}"
  end
end
