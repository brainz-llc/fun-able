class CreateHandCards < ActiveRecord::Migration[8.1]
  def change
    create_table :hand_cards do |t|
      t.references :game_player, null: false, foreign_key: true
      t.references :card, null: false, foreign_key: true

      t.timestamps
    end
    add_index :hand_cards, [:game_player_id, :card_id], unique: true
  end
end
