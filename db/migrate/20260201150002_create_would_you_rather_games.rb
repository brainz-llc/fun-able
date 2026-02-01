class CreateWouldYouRatherGames < ActiveRecord::Migration[8.1]
  def change
    create_table :would_you_rather_games do |t|
      t.string :code, null: false, limit: 6
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0
      t.references :current_card, foreign_key: { to_table: :would_you_rather_cards }
      t.integer :current_round, default: 0
      t.integer :max_rounds, default: 10
      t.string :phase, default: 'waiting'
      t.datetime :voting_ends_at

      t.timestamps
    end

    add_index :would_you_rather_games, :code, unique: true
    add_index :would_you_rather_games, :status
  end
end
