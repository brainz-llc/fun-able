class CreateKingsCupTables < ActiveRecord::Migration[8.1]
  def change
    create_table :kings_cup_games do |t|
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.string :code, limit: 6, null: false
      t.integer :status, default: 0, null: false
      t.integer :max_players, default: 10, null: false
      t.integer :kings_drawn, default: 0, null: false
      t.integer :current_player_index, default: 0, null: false
      t.json :custom_rules, default: {}
      t.json :settings, default: {}

      t.timestamps
    end

    add_index :kings_cup_games, :code, unique: true
    add_index :kings_cup_games, :status

    create_table :kings_cup_players do |t|
      t.references :kings_cup_game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :position
      t.integer :status, default: 0, null: false
      t.integer :mate_player_id
      t.boolean :is_question_master, default: false, null: false
      t.datetime :connected_at
      t.datetime :disconnected_at

      t.timestamps
    end

    add_index :kings_cup_players, [:kings_cup_game_id, :user_id], unique: true
    add_index :kings_cup_players, [:kings_cup_game_id, :status]

    create_table :kings_cup_cards do |t|
      t.references :kings_cup_game, null: false, foreign_key: true
      t.references :drawn_by, foreign_key: { to_table: :kings_cup_players }
      t.string :suit, limit: 10, null: false
      t.string :value, limit: 5, null: false
      t.boolean :drawn, default: false, null: false
      t.datetime :drawn_at

      t.timestamps
    end

    add_index :kings_cup_cards, [:kings_cup_game_id, :drawn]
    add_index :kings_cup_cards, [:kings_cup_game_id, :suit, :value], unique: true

    create_table :kings_cup_rules do |t|
      t.references :kings_cup_game, null: false, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :kings_cup_players }
      t.text :rule_text, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :kings_cup_rules, [:kings_cup_game_id, :active]
  end
end
