class CreateNeverHaveIEverUsedCards < ActiveRecord::Migration[8.1]
  def change
    create_table :never_have_i_ever_used_cards do |t|
      t.references :never_have_i_ever_game, null: false, foreign_key: true
      t.references :never_have_i_ever_card, null: false, foreign_key: true

      t.timestamps
    end

    add_index :never_have_i_ever_used_cards, [:never_have_i_ever_game_id, :never_have_i_ever_card_id], unique: true, name: 'idx_nhie_used_cards_game_card'
  end
end
