class CreateDeckVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :deck_votes do |t|
      t.references :deck, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :value, null: false, default: 1

      t.timestamps
    end
    add_index :deck_votes, [:deck_id, :user_id], unique: true
  end
end
