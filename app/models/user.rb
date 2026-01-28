class User < ApplicationRecord
  has_secure_password validations: false

  # Associations
  has_many :created_decks, class_name: 'Deck', foreign_key: :creator_id, dependent: :nullify
  has_many :deck_votes, dependent: :destroy
  has_many :voted_decks, through: :deck_votes, source: :deck
  has_many :hosted_games, class_name: 'Game', foreign_key: :host_id, dependent: :nullify
  has_many :game_players, dependent: :destroy
  has_many :games, through: :game_players

  # Validations
  validates :display_name, presence: true, length: { minimum: 2, maximum: 30 }
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :session_token, presence: true, uniqueness: true

  # Callbacks
  before_validation :ensure_session_token, on: :create
  before_validation :generate_guest_name, if: -> { display_name.blank? && is_guest? }

  # Scopes
  scope :guests, -> { where(is_guest: true) }
  scope :registered, -> { where(is_guest: false) }
  scope :active_recently, -> { where('updated_at > ?', 1.week.ago) }

  # Class methods
  def self.create_guest!
    create!(
      display_name: generate_guest_name_static,
      is_guest: true,
      stats: default_stats
    )
  end

  def self.generate_guest_name_static
    adjectives = %w[Feliz Loco Valiente Genial Super Mega Ultra Turbo]
    nouns = %w[Taco Burrito Nacho Churro Piñata Fiesta Salsa Guacamole]
    "#{adjectives.sample}#{nouns.sample}#{rand(100..999)}"
  end

  def self.default_stats
    {
      games_played: 0,
      games_won: 0,
      rounds_won: 0,
      favorite_deck_id: nil
    }
  end

  # Instance methods
  def guest?
    is_guest?
  end

  def registered?
    !is_guest? && email.present?
  end

  def upgrade_to_registered!(email:, password:)
    return false if registered?

    self.email = email
    self.password = password
    self.is_guest = false
    save
  end

  def avatar_initials
    display_name.to_s.split.map(&:first).join.upcase[0, 2]
  end

  def increment_stat!(stat_name, amount = 1)
    current_stats = stats || {}
    current_stats[stat_name.to_s] = (current_stats[stat_name.to_s] || 0) + amount
    update!(stats: current_stats)
  end

  def regenerate_session_token!
    update!(session_token: generate_session_token)
  end

  private

  def ensure_session_token
    self.session_token ||= generate_session_token
  end

  def generate_session_token
    loop do
      token = SecureRandom.urlsafe_base64(32)
      break token unless User.exists?(session_token: token)
    end
  end

  def generate_guest_name
    self.display_name = self.class.generate_guest_name_static
  end
end
