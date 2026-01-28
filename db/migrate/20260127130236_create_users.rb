class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :display_name, null: false
      t.string :email
      t.string :password_digest
      t.string :session_token, null: false
      t.boolean :is_guest, null: false, default: false
      t.json :stats, default: {}

      t.timestamps
    end
    add_index :users, :session_token, unique: true
    add_index :users, :email, unique: true, where: "email IS NOT NULL"
  end
end
