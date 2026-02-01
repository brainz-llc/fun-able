class CreateNeverHaveIEverCards < ActiveRecord::Migration[8.1]
  def change
    create_table :never_have_i_ever_cards do |t|
      t.text :content, null: false
      t.integer :category, null: false, default: 0  # tame: 0, spicy: 1, extreme: 2

      t.timestamps
    end

    add_index :never_have_i_ever_cards, :category
  end
end
