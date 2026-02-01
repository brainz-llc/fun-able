class MostLikelyToGame < ApplicationRecord
  # Associations
  belongs_to :host, class_name: 'User'
  belongs_to :current_card, class_name: 'MostLikelyToCard', optional: true
  has_many :most_likely_to_players, dependent: :destroy
  has_many :players, through: :most_likely_to_players, source: :user
  has_many :most_likely_to_votes, dependent: :destroy

  # Enums
  enum :status, { lobby: 0, playing: 1, paused: 2, finished: 3 }

  # Validations
  validates :code, presence: true, uniqueness: true, length: { is: 6 }
  validates :max_players, numericality: { in: 2..20 }
  validates :total_rounds, numericality: { in: 5..30 }

  # Callbacks
  before_validation :generate_code, on: :create

  # Scopes
  scope :active, -> { where(status: [:lobby, :playing, :paused]) }
  scope :joinable, -> { lobby.where('(SELECT COUNT(*) FROM most_likely_to_players WHERE most_likely_to_players.most_likely_to_game_id = most_likely_to_games.id) < most_likely_to_games.max_players') }
  scope :recent, -> { order(created_at: :desc) }

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
    most_likely_to_players.where(status: [:active, :disconnected]).order(:position)
  end

  def player_count
    most_likely_to_players.count
  end

  def full?
    player_count >= max_players
  end

  def joinable?
    lobby? && !full?
  end

  def can_start?
    lobby? && player_count >= 3
  end

  def player_for(user)
    most_likely_to_players.find_by(user: user)
  end

  def has_player?(user)
    most_likely_to_players.exists?(user: user)
  end

  def host?(user)
    host_id == user.id
  end

  def add_player!(user)
    return most_likely_to_players.find_by(user: user) if has_player?(user)
    return nil if full?

    most_likely_to_players.create!(
      user: user,
      connected_at: Time.current,
      position: most_likely_to_players.maximum(:position).to_i + 1
    )
  end

  def remove_player!(user)
    player = player_for(user)
    return unless player

    if host?(user) && player_count > 1
      new_host = active_players.where.not(user: user).order(:position).first&.user
      update!(host: new_host) if new_host
    end

    remaining_count = player_count - 1
    if playing? && remaining_count < 3
      finish!
      MostLikelyToChannel.broadcast_game_ended(self)
    end

    player.destroy
  end

  def start!
    return false unless can_start?

    transaction do
      update!(
        status: :playing,
        current_round: 1,
        phase: 'voting',
        used_card_ids: []
      )
      draw_new_card!
    end
    true
  end

  def finish!
    update!(status: :finished, phase: 'results')
  end

  def draw_new_card!
    card = MostLikelyToCard.where.not(id: used_card_ids).shuffled.first

    if card.nil?
      update!(used_card_ids: [])
      card = MostLikelyToCard.shuffled.first
    end

    if card
      card.record_play!
      update!(
        current_card: card,
        used_card_ids: used_card_ids + [card.id],
        phase: 'voting'
      )
    end

    card
  end

  def votes_for_round(round = current_round)
    most_likely_to_votes.where(round_number: round)
  end

  def all_voted?
    votes_for_round.count >= active_players.count
  end

  def vote_counts
    votes_for_round
      .joins(:voted_for)
      .group(:voted_for_id)
      .count
  end

  def winners
    counts = vote_counts
    return [] if counts.empty?

    max_votes = counts.values.max
    winner_ids = counts.select { |_, v| v == max_votes }.keys
    most_likely_to_players.where(id: winner_ids)
  end

  def reveal_results!
    update!(phase: 'revealing')

    # Award drinks to winners
    winners.each(&:drink!)
  end

  def next_round!
    if current_round >= total_rounds
      finish!
      return false
    end

    transaction do
      update!(current_round: current_round + 1)
      draw_new_card!
    end
    true
  end

  def broadcast_channel
    "most_likely_to_game_#{id}"
  end

  def leaderboard
    most_likely_to_players.order(drinks: :desc)
  end

  private

  def generate_code
    self.code ||= self.class.generate_unique_code
  end
end
