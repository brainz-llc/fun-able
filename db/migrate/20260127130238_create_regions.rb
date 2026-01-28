class CreateRegions < ActiveRecord::Migration[8.1]
  def change
    create_table :regions do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :emoji_flag
      t.integer :parent_id
      t.boolean :active, null: false, default: true
      t.integer :position, default: 0

      t.timestamps
    end
    add_index :regions, :parent_id
    add_index :regions, :code, unique: true
    add_index :regions, [:active, :position]
  end
end
