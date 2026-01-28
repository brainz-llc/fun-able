class CreateSubmissionCards < ActiveRecord::Migration[8.1]
  def change
    create_table :submission_cards do |t|
      t.references :card_submission, null: false, foreign_key: true
      t.references :card, null: false, foreign_key: true
      t.integer :play_order, null: false, default: 1

      t.timestamps
    end
    add_index :submission_cards, [:card_submission_id, :play_order]
  end
end
