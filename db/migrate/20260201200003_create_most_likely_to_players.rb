class CreateMostLikelyToPlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :most_likely_to_players do |t|
      t.references :most_likely_to_game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.integer :position
      t.integer :drinks, default: 0, null: false
      t.datetime :connected_at
      t.datetime :disconnected_at

      t.timestamps
    end

    add_index :most_likely_to_players, [:most_likely_to_game_id, :user_id], unique: true, name: 'idx_mlt_players_game_user'
    add_index :most_likely_to_players, [:most_likely_to_game_id, :status], name: 'idx_mlt_players_game_status'
  end
end
