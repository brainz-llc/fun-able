class Game < ApplicationRecord
  # Associations
  belongs_to :host, class_name: 'User'
  belongs_to :deck, optional: true
  has_many :game_players, dependent: :destroy
  has_many :players, through: :game_players, source: :user
  has_many :rounds, dependent: :destroy

  # Enums
  enum :status, { lobby: 0, playing: 1, paused: 2, finished: 3 }

  # Validations
  validates :code, presence: true, uniqueness: true, length: { is: 6 }
  validates :points_to_win, numericality: { in: 3..20 }
  validates :turn_timer, numericality: { in: 30..180 }
  validates :max_players, numericality: { in: 3..20 }
  validate :deck_must_be_playable, on: :update, if: :playing?

  # Callbacks
  before_validation :generate_code, on: :create

  # Scopes
  scope :active, -> { where(status: [:lobby, :playing, :paused]) }
  scope :joinable, -> { lobby.where('(SELECT COUNT(*) FROM game_players WHERE game_players.game_id = games.id AND game_players.is_spectator = false) < games.max_players') }
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
  def current_round
    rounds.order(round_number: :desc).first
  end

  def active_players
    game_players.active.playing
  end

  def spectators
    game_players.spectators
  end

  def player_count
    game_players.playing.count
  end

  def spectator_count
    game_players.spectators.count
  end

  def full?
    player_count >= max_players
  end

  def joinable?
    lobby? && !full?
  end

  def can_start?
    lobby? && player_count >= 3 && deck&.playable?
  end

  def player_for(user)
    game_players.find_by(user: user)
  end

  def has_player?(user)
    game_players.exists?(user: user)
  end

  def host?(user)
    host_id == user.id
  end

  def add_player!(user, spectator: false)
    return game_players.find_by(user: user) if has_player?(user)
    return nil if full? && !spectator

    game_players.create!(
      user: user,
      is_spectator: spectator,
      connected_at: Time.current,
      position: game_players.maximum(:position).to_i + 1
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

    # Handle if leaving player is the current judge
    if playing? && current_round&.judge_id == player.id
      handle_judge_leaving!(player)
    end

    # Check if enough players remain
    remaining_count = player_count - 1
    if playing? && remaining_count < 3
      finish!
      GameChannel.broadcast_game_ended(self)
    end

    player.destroy
  end

  def handle_judge_leaving!(judge_player)
    round = current_round
    return unless round

    if round.judging? || round.revealing?
      # Auto-select random winner if in judging phase
      random_submission = round.card_submissions.sample
      if random_submission
        round.select_winner!(random_submission)
        GameChannel.broadcast_winner_selected(self, round, random_submission)
      else
        round.update!(phase: :complete)
      end
    elsif round.submitting?
      # Complete the round without a winner
      round.update!(phase: :complete)
    end
  end

  def start!
    return false unless can_start?

    transaction do
      update!(status: :playing)
      start_new_round!
    end
    true
  end

  def start_new_round!
    next_judge = select_next_judge
    next_black_card = select_black_card

    round = rounds.create!(
      round_number: (current_round&.round_number || 0) + 1,
      judge: next_judge,
      black_card: next_black_card,
      phase: :submitting,
      timer_expires_at: turn_timer.seconds.from_now
    )

    deal_cards_to_all_players!
    round
  end

  def finish!
    update!(status: :finished)
  end

  def winner
    return nil unless finished?
    game_players.order(score: :desc).first
  end

  def leaderboard
    game_players.playing.order(score: :desc)
  end

  def broadcast_channel
    "game_#{id}"
  end

  private

  def generate_code
    self.code ||= self.class.generate_unique_code
  end

  def deck_must_be_playable
    errors.add(:deck, 'debe ser jugable') unless deck&.playable?
  end

  def select_next_judge
    last_judge_position = current_round&.judge&.position
    players = active_players.order(:position)

    if last_judge_position
      # Find next player after current judge
      next_player = players.where('position > ?', last_judge_position).first
      next_player || players.first
    else
      players.first
    end
  end

  def select_black_card
    used_card_ids = rounds.pluck(:black_card_id)
    available_cards = deck.black_cards.where.not(id: used_card_ids)

    # If all cards used, reset
    available_cards = deck.black_cards if available_cards.empty?

    available_cards.shuffled.first
  end

  def deal_cards_to_all_players!
    active_players.each do |player|
      player.deal_cards_to_hand_size!
    end
  end
end
