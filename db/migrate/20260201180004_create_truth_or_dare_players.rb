class CreateTruthOrDarePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :truth_or_dare_players do |t|
      t.references :truth_or_dare_game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :position, default: 0, null: false
      t.integer :drinks_taken, default: 0, null: false
      t.integer :truths_completed, default: 0, null: false
      t.integer :dares_completed, default: 0, null: false
      t.integer :status, default: 0, null: false # 0: active, 1: disconnected, 2: left, 3: kicked
      t.datetime :connected_at
      t.datetime :disconnected_at

      t.timestamps
    end

    add_index :truth_or_dare_players, [:truth_or_dare_game_id, :user_id], unique: true, name: 'idx_tod_players_game_user'
    add_index :truth_or_dare_players, [:truth_or_dare_game_id, :status], name: 'idx_tod_players_game_status'
  end
end
