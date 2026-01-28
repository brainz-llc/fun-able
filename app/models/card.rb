class Card < ApplicationRecord
  # Associations
  belongs_to :deck, optional: true
  has_many :deck_cards, dependent: :destroy
  has_many :decks, through: :deck_cards
  has_many :hand_cards, dependent: :destroy
  has_many :submission_cards, dependent: :destroy
  has_many :rounds_as_black, class_name: 'Round', foreign_key: :black_card_id, dependent: :nullify
  has_one_attached :meme_image

  # Enums
  enum :card_type, { black: 0, white: 1 }
  enum :meme_type, { text_only: 0, image_meme: 1, gif_meme: 2 }

  # Validations
  validates :content, presence: true, length: { minimum: 1, maximum: 500 }
  validates :pick_count, numericality: { in: 1..3 }, if: :black?

  # Scopes
  scope :for_deck, ->(deck_id) { where(deck_id: deck_id) }
  scope :shuffled, -> { order('RANDOM()') }

  # Callbacks
  before_validation :set_defaults

  # Instance methods
  def display_content
    content
  end

  def display_content_with_blanks
    return content if white?

    # Count blanks in content
    blank_count = content.scan('_____').count
    if blank_count.zero?
      # No explicit blanks, add one at the end
      "#{content} _____"
    else
      content
    end
  end

  def blanks_count
    return 0 if white?
    count = content.scan('_____').count
    count.zero? ? 1 : count
  end

  def display_meme_url
    if meme_image.attached?
      # Return Active Storage URL
      meme_image
    elsif meme_url.present?
      meme_url
    end
  end

  def has_meme?
    !text_only?
  end

  def css_class
    black? ? 'card-black' : 'card-white'
  end

  def duplicate_for_deck(target_deck)
    target_deck.owned_cards.create!(
      content: content,
      card_type: card_type,
      pick_count: pick_count,
      meme_type: meme_type,
      meme_url: meme_url
    )
  end

  private

  def set_defaults
    self.pick_count ||= 1 if black?
    self.pick_count = 1 if white?
    self.meme_type ||= :text_only
  end
end
