class CreateGamePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :game_players do |t|
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :score, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.boolean :is_spectator, null: false, default: false
      t.datetime :connected_at
      t.datetime :disconnected_at
      t.integer :position

      t.timestamps
    end
    add_index :game_players, [:game_id, :user_id], unique: true
    add_index :game_players, [:game_id, :status]
  end
end
