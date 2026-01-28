class CreateDecks < ActiveRecord::Migration[8.1]
  def change
    create_table :decks do |t|
      t.string :name, null: false
      t.text :description
      t.references :creator, foreign_key: { to_table: :users }
      t.references :region, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :content_rating, null: false, default: 1
      t.integer :votes_count, null: false, default: 0
      t.boolean :official, null: false, default: false

      t.timestamps
    end
    add_index :decks, [:status, :content_rating]
    add_index :decks, :official
  end
end
