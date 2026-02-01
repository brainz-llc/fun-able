class CreateTruthCards < ActiveRecord::Migration[8.1]
  def change
    create_table :truth_cards do |t|
      t.text :content, null: false
      t.integer :intensity, default: 0, null: false # 0: mild, 1: medium, 2: spicy

      t.timestamps
    end

    add_index :truth_cards, :intensity
  end
end
