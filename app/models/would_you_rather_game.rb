class WouldYouRatherGame < ApplicationRecord
  # Associations
  belongs_to :host, class_name: 'User'
  belongs_to :current_card, class_name: 'WouldYouRatherCard', optional: true
  has_many :would_you_rather_players, dependent: :destroy
  has_many :players, through: :would_you_rather_players, source: :user
  has_many :would_you_rather_votes, dependent: :destroy

  # Enums
  enum :status, { lobby: 0, playing: 1, finished: 2 }

  # Validations
  validates :code, presence: true, uniqueness: true, length: { is: 6 }
  validates :max_rounds, numericality: { in: 5..30 }

  # Callbacks
  before_validation :generate_code, on: :create

  # Scopes
  scope :active, -> { where(status: [:lobby, :playing]) }
  scope :joinable, -> { lobby }

  # Class methods
  def self.find_by_code(code)
    find_by(code: code&.upcase&.strip)
  end

  def self.generate_unique_code
    loop do
      code = SecureRandom.alphanumeric(6).upcase
      break code unless exists?(code: code)
    end
  end

  # Instance methods
  def active_players
    would_you_rather_players.where(status: [:active, :disconnected])
  end

  def player_count
    would_you_rather_players.count
  end

  def joinable?
    lobby?
  end

  def can_start?
    lobby? && player_count >= 2
  end

  def player_for(user)
    would_you_rather_players.find_by(user: user)
  end

  def has_player?(user)
    would_you_rather_players.exists?(user: user)
  end

  def host?(user)
    host_id == user.id
  end

  def add_player!(user)
    return would_you_rather_players.find_by(user: user) if has_player?(user)

    would_you_rather_players.create!(
      user: user,
      is_host: host_id == user.id,
      connected_at: Time.current
    )
  end

  def remove_player!(user)
    player = player_for(user)
    return unless player

    if host?(user) && player_count > 1
      new_host = active_players.where.not(user: user).first&.user
      update!(host: new_host) if new_host
    end

    player.destroy

    finish! if playing? && player_count < 2
  end

  def start!
    return false unless can_start?

    transaction do
      update!(status: :playing, current_round: 0)
      next_round!
    end
    true
  end

  def next_round!
    return finish! if current_round >= max_rounds

    used_card_ids = would_you_rather_votes.distinct.pluck(:would_you_rather_card_id)
    available_cards = WouldYouRatherCard.where.not(id: used_card_ids)
    available_cards = WouldYouRatherCard.all if available_cards.empty?

    new_card = available_cards.shuffled.first

    update!(
      current_card: new_card,
      current_round: current_round + 1,
      phase: 'voting',
      voting_ends_at: 30.seconds.from_now
    )
  end

  def votes_for_current_round
    would_you_rather_votes.where(round_number: current_round)
  end

  def all_voted?
    votes_for_current_round.count >= active_players.count
  end

  def reveal_votes!
    return unless all_voted? || voting_ended?

    update!(phase: 'revealing')

    votes = votes_for_current_round
    option_a_votes = votes.where(choice: 'a').count
    option_b_votes = votes.where(choice: 'b').count

    # Determine minority
    minority_choice = if option_a_votes < option_b_votes
                        'a'
                      elsif option_b_votes < option_a_votes
                        'b'
                      else
                        nil # Tie - no one drinks
                      end

    winning_choice = minority_choice == 'a' ? 'b' : 'a' if minority_choice

    # Update player stats
    if minority_choice
      minority_voters = votes.where(choice: minority_choice)
      majority_voters = votes.where.not(choice: minority_choice)

      minority_voters.each do |vote|
        vote.would_you_rather_player.drink!
      end

      majority_voters.each do |vote|
        vote.would_you_rather_player.increment_streak!
      end
    end

    # Update card stats
    current_card&.record_play!(winning_choice) if winning_choice

    {
      option_a_votes: option_a_votes,
      option_b_votes: option_b_votes,
      minority_choice: minority_choice,
      minority_player_ids: minority_choice ? votes.where(choice: minority_choice).pluck(:would_you_rather_player_id) : []
    }
  end

  def voting_ended?
    voting_ends_at.present? && Time.current >= voting_ends_at
  end

  def finish!
    update!(status: :finished, phase: 'finished')
  end

  def broadcast_channel
    "would_you_rather_game_#{id}"
  end

  def leaderboard
    would_you_rather_players.order(drinks_taken: :asc, max_streak: :desc)
  end

  private

  def generate_code
    self.code ||= self.class.generate_unique_code
  end
end
