class CreateWouldYouRatherPlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :would_you_rather_players do |t|
      t.references :would_you_rather_game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :drinks_taken, default: 0
      t.integer :times_in_minority, default: 0
      t.integer :current_streak, default: 0
      t.integer :max_streak, default: 0
      t.boolean :is_host, default: false
      t.integer :status, default: 0
      t.datetime :connected_at

      t.timestamps
    end

    add_index :would_you_rather_players, [:would_you_rather_game_id, :user_id], unique: true, name: 'idx_wyr_players_game_user'
  end
end
