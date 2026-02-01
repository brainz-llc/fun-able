class CreateMostLikelyToVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :most_likely_to_votes do |t|
      t.references :most_likely_to_game, null: false, foreign_key: true
      t.references :voter, null: false, foreign_key: { to_table: :most_likely_to_players }
      t.references :voted_for, null: false, foreign_key: { to_table: :most_likely_to_players }
      t.integer :round_number, null: false

      t.timestamps
    end

    add_index :most_likely_to_votes, [:most_likely_to_game_id, :round_number, :voter_id], unique: true, name: 'idx_mlt_votes_unique_per_round'
    add_index :most_likely_to_votes, [:most_likely_to_game_id, :round_number], name: 'idx_mlt_votes_round'
  end
end
