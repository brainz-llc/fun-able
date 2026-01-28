class SubmissionCard < ApplicationRecord
  belongs_to :card_submission
  belongs_to :card

  validates :play_order, presence: true, numericality: { greater_than: 0 }

  scope :in_order, -> { order(:play_order) }
end
