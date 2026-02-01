class CreateTruthOrDareGames < ActiveRecord::Migration[8.1]
  def change
    create_table :truth_or_dare_games do |t|
      t.string :code, limit: 6, null: false
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false # 0: lobby, 1: playing, 2: paused, 3: finished
      t.integer :max_players, default: 10, null: false
      t.integer :intensity_level, default: 0, null: false # 0: mild, 1: medium, 2: spicy
      t.integer :current_player_index, default: 0, null: false
      t.json :used_truth_ids, default: []
      t.json :used_dare_ids, default: []
      t.json :settings, default: {}

      t.timestamps
    end

    add_index :truth_or_dare_games, :code, unique: true
    add_index :truth_or_dare_games, :status
  end
end
