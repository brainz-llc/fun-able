class KingsCupGame < ApplicationRecord
  # Associations
  belongs_to :host, class_name: 'User'
  has_many :kings_cup_players, dependent: :destroy
  has_many :players, through: :kings_cup_players, source: :user
  has_many :kings_cup_cards, dependent: :destroy
  has_many :kings_cup_rules, dependent: :destroy

  # Enums
  enum :status, { lobby: 0, playing: 1, paused: 2, finished: 3 }

  # Validations
  validates :code, presence: true, uniqueness: true, length: { is: 6 }
  validates :max_players, numericality: { in: 2..20 }

  # Callbacks
  before_validation :generate_code, on: :create

  # Scopes
  scope :active, -> { where(status: [:lobby, :playing, :paused]) }
  scope :joinable, -> { lobby.where('(SELECT COUNT(*) FROM kings_cup_players WHERE kings_cup_players.kings_cup_game_id = kings_cup_games.id) < kings_cup_games.max_players') }
  scope :recent, -> { order(created_at: :desc) }

  # Card rules in Spanish
  CARD_RULES = {
    'A' => {
      name: 'Cascada',
      description: 'Todos beben en secuencia. El que saco la carta empieza, el siguiente no puede parar hasta que el anterior pare.',
      icon: '🌊'
    },
    '2' => {
      name: 'Tu',
      description: 'Elige a alguien para que beba.',
      icon: '👉'
    },
    '3' => {
      name: 'Yo',
      description: 'Tu bebes.',
      icon: '🍺'
    },
    '4' => {
      name: 'Suelo',
      description: 'El ultimo en tocar el suelo bebe.',
      icon: '👇'
    },
    '5' => {
      name: 'Chicos',
      description: 'Todos los chicos beben.',
      icon: '👨'
    },
    '6' => {
      name: 'Chicas',
      description: 'Todas las chicas beben.',
      icon: '👩'
    },
    '7' => {
      name: 'Cielo',
      description: 'El ultimo en levantar la mano bebe.',
      icon: '🙋'
    },
    '8' => {
      name: 'Compinche',
      description: 'Elige un compinche. Cada vez que tu bebas, el tambien bebe.',
      icon: '🤝'
    },
    '9' => {
      name: 'Rima',
      description: 'Di una palabra. Los demas deben decir palabras que rimen. El que falle bebe.',
      icon: '🎤'
    },
    '10' => {
      name: 'Categorias',
      description: 'Elige una categoria. Cada uno dice algo de esa categoria. El que repita o falle bebe.',
      icon: '📋'
    },
    'J' => {
      name: 'Regla Nueva',
      description: 'Crea una regla que todos deben seguir. Quien la rompa, bebe.',
      icon: '📜'
    },
    'Q' => {
      name: 'Maestro de Preguntas',
      description: 'Eres el Maestro de Preguntas. Si alguien responde una pregunta tuya, bebe.',
      icon: '❓'
    },
    'K' => {
      name: 'Copa del Rey',
      description: 'Vierte un poco de tu bebida en la Copa del Rey. El que saque el 4to Rey, la bebe toda!',
      icon: '👑'
    }
  }.freeze

  SUITS = %w[hearts diamonds clubs spades].freeze
  SUIT_SYMBOLS = {
    'hearts' => '♥️',
    'diamonds' => '♦️',
    'clubs' => '♣️',
    'spades' => '♠️'
  }.freeze
  SUIT_COLORS = {
    'hearts' => 'red',
    'diamonds' => 'red',
    'clubs' => 'black',
    'spades' => 'black'
  }.freeze
  VALUES = %w[A 2 3 4 5 6 7 8 9 10 J Q K].freeze

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
    kings_cup_players.where(status: [:active, :disconnected])
  end

  def player_count
    kings_cup_players.count
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
    kings_cup_players.find_by(user: user)
  end

  def has_player?(user)
    kings_cup_players.exists?(user: user)
  end

  def host?(user)
    host_id == user.id
  end

  def add_player!(user)
    return kings_cup_players.find_by(user: user) if has_player?(user)
    return nil if full?

    kings_cup_players.create!(
      user: user,
      connected_at: Time.current,
      position: kings_cup_players.maximum(:position).to_i + 1
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
      KingsCupChannel.broadcast_game_ended(self)
    end

    player.destroy
  end

  def start!
    return false unless can_start?

    transaction do
      update!(status: :playing)
      create_deck!
    end
    true
  end

  def create_deck!
    kings_cup_cards.destroy_all

    SUITS.each do |suit|
      VALUES.each do |value|
        kings_cup_cards.create!(suit: suit, value: value, drawn: false)
      end
    end
  end

  def cards_remaining
    kings_cup_cards.where(drawn: false).count
  end

  def drawn_cards
    kings_cup_cards.where(drawn: true).order(drawn_at: :desc)
  end

  def current_player
    active_players.order(:position)[current_player_index % active_players.count] if active_players.any?
  end

  def advance_turn!
    update!(current_player_index: (current_player_index + 1) % active_players.count)
  end

  def draw_card!(player)
    return nil unless playing?
    return nil unless current_player&.id == player.id

    card = kings_cup_cards.where(drawn: false).order('RANDOM()').first
    return nil unless card

    card.update!(drawn: true, drawn_at: Time.current, drawn_by: player)

    # Handle Kings
    if card.value == 'K'
      increment!(:kings_drawn)
      if kings_drawn >= 4
        finish!
      end
    end

    # Handle Question Master
    if card.value == 'Q'
      kings_cup_players.update_all(is_question_master: false)
      player.update!(is_question_master: true)
    end

    advance_turn! unless finished?

    card
  end

  def finish!
    update!(status: :finished)
  end

  def cup_fill_percentage
    (kings_drawn.to_f / 4 * 100).clamp(0, 100)
  end

  def active_rules
    kings_cup_rules.where(active: true).order(created_at: :desc)
  end

  def question_master
    kings_cup_players.find_by(is_question_master: true)
  end

  def broadcast_channel
    "kings_cup_game_#{id}"
  end

  private

  def generate_code
    self.code ||= self.class.generate_unique_code
  end
end
