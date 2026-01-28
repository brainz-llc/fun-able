class Region < ApplicationRecord
  # Self-referential for hierarchy
  belongs_to :parent, class_name: 'Region', optional: true
  has_many :children, class_name: 'Region', foreign_key: :parent_id, dependent: :nullify

  # Associations
  has_many :decks, dependent: :nullify

  # Validations
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true, length: { is: 2 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :sorted, -> { order(:position, :name) }
  scope :roots, -> { where(parent_id: nil) }
  scope :with_children, -> { includes(:children) }

  # Class methods
  def self.for_select
    active.sorted.map { |r| [r.display_name, r.id] }
  end

  def self.grouped_for_select
    roots.active.sorted.includes(:children).map do |root|
      [
        root.display_name,
        root.children.active.sorted.map { |c| [c.display_name, c.id] }
      ]
    end
  end

  # Instance methods
  def display_name
    [emoji_flag, name].compact.join(' ')
  end

  def root?
    parent_id.nil?
  end

  def leaf?
    children.empty?
  end

  def ancestors
    return [] if root?
    [parent] + parent.ancestors
  end

  def descendants
    children.flat_map { |c| [c] + c.descendants }
  end

  def self_and_descendants
    [self] + descendants
  end

  def deck_count
    decks.published.count
  end
end
