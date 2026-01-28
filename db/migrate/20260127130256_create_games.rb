class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :code, null: false, limit: 6
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.references :deck, foreign_key: true
      t.integer :status, null: false, default: 0
      t.json :settings, default: {}
      t.integer :points_to_win, null: false, default: 10
      t.integer :turn_timer, null: false, default: 60
      t.integer :max_players, null: false, default: 10

      t.timestamps
    end
    add_index :games, :code, unique: true
    add_index :games, :status
  end
end
