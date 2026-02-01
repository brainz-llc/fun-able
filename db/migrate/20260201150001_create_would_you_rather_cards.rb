class CreateWouldYouRatherCards < ActiveRecord::Migration[8.1]
  def change
    create_table :would_you_rather_cards do |t|
      t.text :option_a, null: false
      t.text :option_b, null: false
      t.string :category, default: 'general'
      t.integer :times_played, default: 0
      t.integer :option_a_wins, default: 0
      t.integer :option_b_wins, default: 0

      t.timestamps
    end

    add_index :would_you_rather_cards, :category
  end
end
