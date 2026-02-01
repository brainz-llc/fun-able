class CreateNeverHaveIEverPlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :never_have_i_ever_players do |t|
      t.references :never_have_i_ever_game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :points, null: false, default: 3
      t.integer :position
      t.integer :status, null: false, default: 0  # active: 0, disconnected: 1, left: 2, kicked: 3
      t.datetime :connected_at
      t.datetime :disconnected_at
      t.boolean :drank_this_round, default: false

      t.timestamps
    end

    add_index :never_have_i_ever_players, [:never_have_i_ever_game_id, :user_id], unique: true, name: 'idx_nhie_players_game_user'
    add_index :never_have_i_ever_players, [:never_have_i_ever_game_id, :status], name: 'idx_nhie_players_game_status'
  end
end
