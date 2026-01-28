class DeckVote < ApplicationRecord
  belongs_to :deck, counter_cache: false, touch: true
  belongs_to :user

  validates :deck_id, uniqueness: { scope: :user_id }
  validates :value, inclusion: { in: [-1, 1] }

  after_commit :update_deck_votes_count

  private

  def update_deck_votes_count
    deck.update_column(:votes_count, deck.deck_votes.sum(:value))
  end
end
