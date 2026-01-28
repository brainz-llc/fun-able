class CardSubmission < ApplicationRecord
  # Associations
  belongs_to :round
  belongs_to :player, class_name: 'GamePlayer'
  has_many :submission_cards, dependent: :destroy
  has_many :cards, through: :submission_cards

  # Validations
  validates :round_id, uniqueness: { scope: :player_id, message: 'Ya enviaste cartas en esta ronda' }
  validate :correct_number_of_cards, on: :create
  validate :player_has_cards, on: :create

  # Scopes
  scope :winners, -> { where(is_winner: true) }
  scope :by_reveal_order, -> { order(:reveal_order) }

  # Instance methods
  def cards_in_order
    submission_cards.includes(:card).order(:play_order).map(&:card)
  end

  def winner?
    is_winner?
  end

  def mark_winner!
    update!(is_winner: true)
  end

  def display_text
    cards_in_order.map(&:content).join(' / ')
  end

  def combined_with_black_card
    black_content = round.black_card.content
    answers = cards_in_order.map(&:content)

    if black_content.include?('_____')
      # Replace blanks with answers
      result = black_content.dup
      answers.each do |answer|
        result = result.sub('_____', "<strong>#{answer}</strong>")
      end
      result
    else
      # Append answer to the end
      "#{black_content} <strong>#{answers.first}</strong>"
    end
  end

  private

  def correct_number_of_cards
    expected = round&.pick_count || 1
    actual = submission_cards.size

    if actual != expected
      errors.add(:base, "Debes seleccionar exactamente #{expected} carta(s)")
    end
  end

  def player_has_cards
    return unless player && submission_cards.any?

    card_ids = submission_cards.map(&:card_id)
    unless player.has_cards?(card_ids)
      errors.add(:base, 'No tienes esas cartas en tu mano')
    end
  end
end
