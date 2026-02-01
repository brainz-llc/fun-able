class KingsCupPlayer < ApplicationRecord
  # Associations
  belongs_to :kings_cup_game
  belongs_to :user
  belongs_to :mate, class_name: 'KingsCupPlayer', foreign_key: :mate_player_id, optional: true
  has_many :drawn_cards, class_name: 'KingsCupCard', foreign_key: :drawn_by_id, dependent: :nullify
  has_many :created_rules, class_name: 'KingsCupRule', foreign_key: :created_by_id, dependent: :nullify

  # Enums
  enum :status, { active: 0, disconnected: 1, left: 2, kicked: 3 }

  # Delegations
  delegate :display_name, :avatar_initials, to: :user

  # Scopes
  scope :by_position, -> { order(:position) }
  scope :connected, -> { where(status: :active) }

  # Methods
  def connected?
    active?
  end

  def host?
    kings_cup_game.host_id == user_id
  end

  def current_turn?
    kings_cup_game.current_player&.id == id
  end

  def mark_connected!
    update!(status: :active, connected_at: Time.current, disconnected_at: nil)
  end

  def mark_disconnected!
    update!(status: :disconnected, disconnected_at: Time.current)
  end

  def set_mate!(other_player)
    transaction do
      # Clear existing mate relationships
      KingsCupPlayer.where(mate_player_id: id).update_all(mate_player_id: nil)
      update!(mate_player_id: other_player.id)
    end
  end

  def clear_mate!
    update!(mate_player_id: nil)
  end
end
