class Deck < ApplicationRecord
  # Associations
  belongs_to :creator, class_name: 'User', optional: true
  belongs_to :region, optional: true
  has_many :deck_cards, dependent: :destroy
  has_many :cards, through: :deck_cards
  has_many :owned_cards, class_name: 'Card', dependent: :destroy
  has_many :deck_votes, dependent: :destroy
  has_many :voters, through: :deck_votes, source: :user
  has_many :games, dependent: :nullify

  # Enums
  enum :status, { draft: 0, published: 1, archived: 2 }
  enum :content_rating, { family: 0, adult: 1, nsfw: 2 }

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, length: { maximum: 500 }
  validate :minimum_cards_for_publishing, if: :published?

  # Scopes
  scope :official, -> { where(official: true) }
  scope :community, -> { where(official: false) }
  scope :by_region, ->(region_id) { where(region_id: region_id) if region_id.present? }
  scope :by_rating, ->(rating) { where(content_rating: rating) if rating.present? }
  scope :popular, -> { order(votes_count: :desc) }
  scope :recent, -> { order(created_at: :desc) }
  scope :playable, -> { where('(SELECT COUNT(*) FROM cards WHERE cards.deck_id = decks.id AND cards.card_type = 0) >= 10 AND (SELECT COUNT(*) FROM cards WHERE cards.deck_id = decks.id AND cards.card_type = 1) >= 25') }

  # Callbacks
  after_touch :update_votes_count

  # Instance methods
  def black_cards
    owned_cards.black
  end

  def white_cards
    owned_cards.white
  end

  def black_cards_count
    black_cards.count
  end

  def white_cards_count
    white_cards.count
  end

  def total_cards_count
    owned_cards.count
  end

  def playable?
    black_cards_count >= 10 && white_cards_count >= 25
  end

  def vote_by(user, value: 1)
    vote = deck_votes.find_or_initialize_by(user: user)
    vote.value = value
    vote.save && touch
  end

  def unvote_by(user)
    deck_votes.find_by(user: user)&.destroy && touch
  end

  def voted_by?(user)
    deck_votes.exists?(user: user)
  end

  def vote_value_by(user)
    deck_votes.find_by(user: user)&.value || 0
  end

  def rating_badge_class
    case content_rating
    when 'family' then 'rating-family'
    when 'adult' then 'rating-adult'
    when 'nsfw' then 'rating-nsfw'
    end
  end

  def publish!
    return false unless playable?
    update!(status: :published)
  end

  def archive!
    update!(status: :archived)
  end

  private

  def minimum_cards_for_publishing
    unless playable?
      errors.add(:base, 'El mazo necesita al menos 10 cartas negras y 25 cartas blancas para publicarse')
    end
  end

  def update_votes_count
    update_column(:votes_count, deck_votes.sum(:value))
  end
end
