class GamePlayer < ApplicationRecord
  HAND_SIZE = 10

  # Associations
  belongs_to :game
  belongs_to :user
  has_many :hand_cards, dependent: :destroy
  has_many :cards_in_hand, through: :hand_cards, source: :card
  has_many :card_submissions, foreign_key: :player_id, dependent: :destroy
  has_many :judged_rounds, class_name: 'Round', foreign_key: :judge_id
  has_many :won_rounds, class_name: 'Round', foreign_key: :winner_id, dependent: :nullify

  # Enums
  enum :status, { active: 0, disconnected: 1, left: 2, kicked: 3 }

  # Validations
  validates :game_id, uniqueness: { scope: :user_id }

  # Scopes
  scope :playing, -> { where(is_spectator: false) }
  scope :spectators, -> { where(is_spectator: true) }
  scope :connected, -> { where.not(connected_at: nil).where(disconnected_at: nil) }
  scope :by_score, -> { order(score: :desc) }
  scope :by_position, -> { order(:position) }

  # Instance methods
  def display_name
    user.display_name
  end

  def avatar_initials
    user.avatar_initials
  end

  def spectator?
    is_spectator?
  end

  def connected?
    connected_at.present? && disconnected_at.nil?
  end

  def disconnected?
    disconnected_at.present?
  end

  def host?
    game.host_id == user_id
  end

  def current_judge?
    game.current_round&.judge_id == id
  end

  def hand_count
    hand_cards.count
  end

  def needs_cards?
    !spectator? && hand_count < HAND_SIZE
  end

  def cards_needed
    HAND_SIZE - hand_count
  end

  def deal_cards_to_hand_size!
    return if spectator?

    needed = cards_needed
    return if needed <= 0

    deal_cards!(needed)
  end

  def deal_cards!(count)
    return if spectator?

    # Get white cards not already in hand
    current_card_ids = hand_cards.pluck(:card_id)
    available_cards = game.deck.white_cards
                          .where.not(id: current_card_ids)
                          .shuffled
                          .limit(count)

    available_cards.each do |card|
      hand_cards.create!(card: card)
    end
  end

  def remove_cards_from_hand!(card_ids)
    hand_cards.where(card_id: card_ids).destroy_all
  end

  def has_cards?(card_ids)
    hand_cards.where(card_id: card_ids).count == card_ids.length
  end

  def submitted_for_round?(round)
    card_submissions.exists?(round: round)
  end

  def submission_for_round(round)
    card_submissions.find_by(round: round)
  end

  def award_point!
    increment!(:score)
    user.increment_stat!(:rounds_won)
  end

  def mark_connected!
    update!(connected_at: Time.current, disconnected_at: nil, status: :active)
  end

  def mark_disconnected!
    update!(disconnected_at: Time.current, status: :disconnected)
  end

  def leave!
    update!(status: :left)
    game.remove_player!(user)
  end

  def kick!
    update!(status: :kicked)
    game.remove_player!(user)
  end
end
