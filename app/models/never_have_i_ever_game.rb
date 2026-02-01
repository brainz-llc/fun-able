class NeverHaveIEverGame < ApplicationRecord
  # Associations
  belongs_to :host, class_name: 'User'
  belongs_to :current_card, class_name: 'NeverHaveIEverCard', optional: true
  has_many :never_have_i_ever_players, dependent: :destroy
  has_many :players, through: :never_have_i_ever_players, source: :user
  has_many :never_have_i_ever_used_cards, dependent: :destroy
  has_many :used_cards, through: :never_have_i_ever_used_cards, source: :never_have_i_ever_card

  # Enums
  enum :status, { lobby: 0, playing: 1, paused: 2, finished: 3 }
  enum :category, { tame: 0, spicy: 1, extreme: 2 }, prefix: :difficulty

  # Validations
  validates :code, presence: true, uniqueness: true, length: { is: 6 }
  validates :max_players, numericality: { in: 2..20 }
  validates :starting_points, numericality: { in: 1..10 }

  # Callbacks
  before_validation :generate_code, on: :create

  # Scopes
  scope :active, -> { where(status: [:lobby, :playing, :paused]) }
  scope :joinable, -> { lobby.where('(SELECT COUNT(*) FROM never_have_i_ever_players WHERE never_have_i_ever_players.never_have_i_ever_game_id = never_have_i_ever_games.id) < never_have_i_ever_games.max_players') }

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
    never_have_i_ever_players.where(status: [:active, :disconnected])
  end

  def player_count
    never_have_i_ever_players.count
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
    never_have_i_ever_players.find_by(user: user)
  end

  def has_player?(user)
    never_have_i_ever_players.exists?(user: user)
  end

  def host?(user)
    host_id == user.id
  end

  def add_player!(user)
    return never_have_i_ever_players.find_by(user: user) if has_player?(user)
    return nil if full?

    never_have_i_ever_players.create!(
      user: user,
      points: starting_points,
      connected_at: Time.current,
      position: never_have_i_ever_players.maximum(:position).to_i + 1
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
    if playing? && remaining_count < 2
      finish!
      NeverHaveIEverChannel.broadcast_game_ended(self)
    end

    player.destroy
  end

  def start!
    return false unless can_start?

    transaction do
      update!(status: :playing, current_reader_position: active_players.order(:position).first&.position)
      draw_next_card!
    end
    true
  end

  def current_reader
    active_players.find_by(position: current_reader_position)
  end

  def draw_next_card!
    available_cards = NeverHaveIEverCard.where(category: category)
                                         .where.not(id: used_cards.pluck(:id))

    # Reset if all cards used
    if available_cards.empty?
      never_have_i_ever_used_cards.destroy_all
      available_cards = NeverHaveIEverCard.where(category: category)
    end

    card = available_cards.shuffled.first
    never_have_i_ever_used_cards.create!(never_have_i_ever_card: card)
    update!(current_card: card)
    card
  end

  def advance_to_next_reader!
    players = active_players.order(:position)
    return if players.empty?

    current_idx = players.find_index { |p| p.position == current_reader_position }
    next_idx = (current_idx + 1) % players.count
    update!(current_reader_position: players[next_idx].position)
  end

  def next_round!
    # Reset drank status for all players
    active_players.update_all(drank_this_round: false)

    # Check for eliminated players
    eliminated = active_players.where('points <= 0')
    eliminated.each do |player|
      NeverHaveIEverChannel.broadcast_player_eliminated(self, player)
    end

    # Check for game over (one player left or all eliminated)
    remaining = active_players.where('points > 0')
    if remaining.count <= 1
      finish!
      NeverHaveIEverChannel.broadcast_game_ended(self)
      return
    end

    advance_to_next_reader!
    draw_next_card!
  end

  def finish!
    update!(status: :finished)
  end

  def winner
    return nil unless finished?
    active_players.order(points: :desc).first
  end

  def leaderboard
    active_players.order(points: :desc)
  end

  def broadcast_channel
    "never_have_i_ever_game_#{id}"
  end

  private

  def generate_code
    self.code ||= self.class.generate_unique_code
  end
end
