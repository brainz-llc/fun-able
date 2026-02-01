class TruthOrDareGame < ApplicationRecord
  # Associations
  belongs_to :host, class_name: 'User'
  has_many :truth_or_dare_players, dependent: :destroy
  has_many :players, through: :truth_or_dare_players, source: :user

  # Enums
  enum :status, { lobby: 0, playing: 1, paused: 2, finished: 3 }
  enum :intensity_level, { mild: 0, medium: 1, spicy: 2 }, prefix: :intensity

  # Validations
  validates :code, presence: true, uniqueness: true, length: { is: 6 }
  validates :max_players, numericality: { in: 2..20 }

  # Callbacks
  before_validation :generate_code, on: :create

  # Scopes
  scope :active, -> { where(status: [:lobby, :playing, :paused]) }
  scope :joinable, -> { lobby.where('(SELECT COUNT(*) FROM truth_or_dare_players WHERE truth_or_dare_players.truth_or_dare_game_id = truth_or_dare_games.id) < truth_or_dare_games.max_players') }
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
    truth_or_dare_players.where(status: [:active, :disconnected]).order(:position)
  end

  def player_count
    truth_or_dare_players.count
  end

  def full?
    player_count >= max_players
  end

  def joinable?
    lobby? && !full?
  end

  def can_start?
    lobby? && player_count >= 2
  end

  def player_for(user)
    truth_or_dare_players.find_by(user: user)
  end

  def has_player?(user)
    truth_or_dare_players.exists?(user: user)
  end

  def host?(user)
    host_id == user.id
  end

  def add_player!(user)
    return truth_or_dare_players.find_by(user: user) if has_player?(user)
    return nil if full?

    truth_or_dare_players.create!(
      user: user,
      connected_at: Time.current,
      position: truth_or_dare_players.maximum(:position).to_i + 1
    )
  end

  def remove_player!(user)
    player = player_for(user)
    return unless player

    if host?(user) && player_count > 1
      # Transfer host to next player
      new_host = active_players.where.not(user: user).order(:position).first&.user
      update!(host: new_host) if new_host
    end

    # Check if enough players remain
    remaining_count = player_count - 1
    if playing? && remaining_count < 2
      finish!
      TruthOrDareChannel.broadcast_game_ended(self)
    end

    player.destroy
  end

  def start!
    return false unless can_start?

    transaction do
      update!(
        status: :playing,
        current_player_index: 0,
        used_truth_ids: [],
        used_dare_ids: []
      )
    end
    true
  end

  def finish!
    update!(status: :finished)
  end

  def current_player
    active_players[current_player_index % active_players.count]
  end

  def advance_turn!
    new_index = (current_player_index + 1) % active_players.count
    update!(current_player_index: new_index)
  end

  def draw_truth_card!
    card = TruthCard.random_for_intensity(intensity_level_before_type_cast, used_truth_ids)

    # If all cards used, reset
    if card.nil?
      update!(used_truth_ids: [])
      card = TruthCard.random_for_intensity(intensity_level_before_type_cast, [])
    end

    if card
      update!(used_truth_ids: used_truth_ids + [card.id])
    end

    card
  end

  def draw_dare_card!
    card = DareCard.random_for_intensity(intensity_level_before_type_cast, used_dare_ids)

    # If all cards used, reset
    if card.nil?
      update!(used_dare_ids: [])
      card = DareCard.random_for_intensity(intensity_level_before_type_cast, [])
    end

    if card
      update!(used_dare_ids: used_dare_ids + [card.id])
    end

    card
  end

  def broadcast_channel
    "truth_or_dare_game_#{id}"
  end

  def leaderboard
    truth_or_dare_players.order(drinks_taken: :asc, truths_completed: :desc, dares_completed: :desc)
  end

  private

  def generate_code
    self.code ||= self.class.generate_unique_code
  end
end
