class CreateVictoryGifs < ActiveRecord::Migration[8.1]
  def change
    create_table :victory_gifs do |t|
      t.string :url, null: false
      t.string :source, default: 'giphy'
      t.integer :category, null: false, default: 0

      t.timestamps
    end
    add_index :victory_gifs, :category
  end
end
