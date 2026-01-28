class HandCard < ApplicationRecord
  belongs_to :game_player
  belongs_to :card

  validates :game_player_id, uniqueness: { scope: :card_id }

  delegate :content, :card_type, :meme_type, :meme_url, to: :card
end
