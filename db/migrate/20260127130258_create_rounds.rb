class CreateRounds < ActiveRecord::Migration[8.1]
  def change
    create_table :rounds do |t|
      t.references :game, null: false, foreign_key: true
      t.references :judge, null: false, foreign_key: { to_table: :game_players }
      t.references :black_card, null: false, foreign_key: { to_table: :cards }
      t.integer :phase, null: false, default: 0
      t.integer :round_number, null: false, default: 1
      t.datetime :timer_expires_at
      t.references :winner, foreign_key: { to_table: :game_players }

      t.timestamps
    end
    add_index :rounds, [:game_id, :round_number], unique: true
    add_index :rounds, [:game_id, :phase]
  end
end
