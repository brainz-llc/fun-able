class CreateMostLikelyToGames < ActiveRecord::Migration[8.1]
  def change
    create_table :most_likely_to_games do |t|
      t.string :code, limit: 6, null: false
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.integer :max_players, default: 10, null: false
      t.integer :current_round, default: 0, null: false
      t.integer :total_rounds, default: 10, null: false
      t.references :current_card, foreign_key: { to_table: :most_likely_to_cards }
      t.json :used_card_ids, default: []
      t.string :phase, default: 'waiting' # waiting, voting, revealing, results

      t.timestamps
    end

    add_index :most_likely_to_games, :code, unique: true
    add_index :most_likely_to_games, :status
  end
end
