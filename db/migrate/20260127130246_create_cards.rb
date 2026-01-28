class CreateCards < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.text :content, null: false
      t.integer :card_type, null: false, default: 1
      t.integer :pick_count, null: false, default: 1
      t.integer :meme_type, null: false, default: 0
      t.string :meme_url
      t.references :deck, foreign_key: true

      t.timestamps
    end
    add_index :cards, :card_type
    add_index :cards, [:deck_id, :card_type]
  end
end
