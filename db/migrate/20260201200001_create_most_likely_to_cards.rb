class CreateMostLikelyToCards < ActiveRecord::Migration[8.1]
  def change
    create_table :most_likely_to_cards do |t|
      t.text :content, null: false
      t.string :category, default: 'general'
      t.integer :times_played, default: 0, null: false

      t.timestamps
    end

    add_index :most_likely_to_cards, :category
  end
end
