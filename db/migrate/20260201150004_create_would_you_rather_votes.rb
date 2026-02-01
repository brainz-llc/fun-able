class CreateWouldYouRatherVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :would_you_rather_votes do |t|
      t.references :would_you_rather_game, null: false, foreign_key: true
      t.references :would_you_rather_player, null: false, foreign_key: true
      t.references :would_you_rather_card, null: false, foreign_key: true
      t.integer :round_number, null: false
      t.string :choice, null: false

      t.timestamps
    end

    add_index :would_you_rather_votes, [:would_you_rather_game_id, :round_number], name: 'idx_wyr_votes_game_round'
    add_index :would_you_rather_votes, [:would_you_rather_game_id, :would_you_rather_player_id, :round_number], unique: true, name: 'idx_wyr_votes_unique_per_round'
  end
end
