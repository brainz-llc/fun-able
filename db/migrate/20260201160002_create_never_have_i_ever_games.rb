class CreateNeverHaveIEverGames < ActiveRecord::Migration[8.1]
  def change
    create_table :never_have_i_ever_games do |t|
      t.string :code, null: false, limit: 6
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0      # lobby: 0, playing: 1, paused: 2, finished: 3
      t.integer :category, null: false, default: 0    # tame: 0, spicy: 1, extreme: 2
      t.integer :max_players, null: false, default: 10
      t.integer :starting_points, null: false, default: 3
      t.integer :current_card_id
      t.integer :current_reader_position

      t.timestamps
    end

    add_index :never_have_i_ever_games, :code, unique: true
    add_index :never_have_i_ever_games, :status
    add_foreign_key :never_have_i_ever_games, :never_have_i_ever_cards, column: :current_card_id
  end
end
