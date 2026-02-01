class CreateDareCards < ActiveRecord::Migration[8.1]
  def change
    create_table :dare_cards do |t|
      t.text :content, null: false
      t.integer :intensity, default: 0, null: false # 0: mild, 1: medium, 2: spicy

      t.timestamps
    end

    add_index :dare_cards, :intensity
  end
end
