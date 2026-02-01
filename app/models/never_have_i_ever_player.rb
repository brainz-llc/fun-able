class NeverHaveIEverPlayer < ApplicationRecord
  # Associations
  belongs_to :never_have_i_ever_game
  belongs_to :user

  # Enums
  enum :status, { active: 0, disconnected: 1, left: 2, kicked: 3 }

  # Scopes
  scope :by_position, -> { order(:position) }
  scope :by_points, -> { order(points: :desc) }
  scope :alive, -> { where('points > 0') }

  # Delegations
  delegate :display_name, :avatar_initials, to: :user

  # Instance methods
  def game
    never_have_i_ever_game
  end

  def connected?
    connected_at.present? && disconnected_at.nil?
  end

  def host?
    game.host_id == user_id
  end

  def current_reader?
    game.current_reader_position == position
  end

  def eliminated?
    points <= 0
  end

  def drink!
    return if drank_this_round?

    decrement!(:points)
    update!(drank_this_round: true)
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
