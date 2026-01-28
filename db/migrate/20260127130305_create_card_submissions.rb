class CreateCardSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :card_submissions do |t|
      t.references :round, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: { to_table: :game_players }
      t.integer :reveal_order
      t.boolean :is_winner, null: false, default: false

      t.timestamps
    end
    add_index :card_submissions, [:round_id, :player_id], unique: true
    add_index :card_submissions, [:round_id, :reveal_order]
  end
end
