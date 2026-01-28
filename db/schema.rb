# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_27_130309) do
  create_table "card_submissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_winner", default: false, null: false
    t.integer "player_id", null: false
    t.integer "reveal_order"
    t.integer "round_id", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_card_submissions_on_player_id"
    t.index ["round_id", "player_id"], name: "index_card_submissions_on_round_id_and_player_id", unique: true
    t.index ["round_id", "reveal_order"], name: "index_card_submissions_on_round_id_and_reveal_order"
    t.index ["round_id"], name: "index_card_submissions_on_round_id"
  end

  create_table "cards", force: :cascade do |t|
    t.integer "card_type", default: 1, null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "deck_id"
    t.integer "meme_type", default: 0, null: false
    t.string "meme_url"
    t.integer "pick_count", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["card_type"], name: "index_cards_on_card_type"
    t.index ["deck_id", "card_type"], name: "index_cards_on_deck_id_and_card_type"
    t.index ["deck_id"], name: "index_cards_on_deck_id"
  end

  create_table "deck_cards", force: :cascade do |t|
    t.integer "card_id", null: false
    t.datetime "created_at", null: false
    t.integer "deck_id", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_deck_cards_on_card_id"
    t.index ["deck_id", "card_id"], name: "index_deck_cards_on_deck_id_and_card_id", unique: true
    t.index ["deck_id"], name: "index_deck_cards_on_deck_id"
  end

  create_table "deck_votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "deck_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "value", default: 1, null: false
    t.index ["deck_id", "user_id"], name: "index_deck_votes_on_deck_id_and_user_id", unique: true
    t.index ["deck_id"], name: "index_deck_votes_on_deck_id"
    t.index ["user_id"], name: "index_deck_votes_on_user_id"
  end

  create_table "decks", force: :cascade do |t|
    t.integer "content_rating", default: 1, null: false
    t.datetime "created_at", null: false
    t.integer "creator_id"
    t.text "description"
    t.string "name", null: false
    t.boolean "official", default: false, null: false
    t.integer "region_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "votes_count", default: 0, null: false
    t.index ["creator_id"], name: "index_decks_on_creator_id"
    t.index ["official"], name: "index_decks_on_official"
    t.index ["region_id"], name: "index_decks_on_region_id"
    t.index ["status", "content_rating"], name: "index_decks_on_status_and_content_rating"
  end

  create_table "game_players", force: :cascade do |t|
    t.datetime "connected_at"
    t.datetime "created_at", null: false
    t.datetime "disconnected_at"
    t.integer "game_id", null: false
    t.boolean "is_spectator", default: false, null: false
    t.integer "position"
    t.integer "score", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["game_id", "status"], name: "index_game_players_on_game_id_and_status"
    t.index ["game_id", "user_id"], name: "index_game_players_on_game_id_and_user_id", unique: true
    t.index ["game_id"], name: "index_game_players_on_game_id"
    t.index ["user_id"], name: "index_game_players_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "code", limit: 6, null: false
    t.datetime "created_at", null: false
    t.integer "deck_id"
    t.integer "host_id", null: false
    t.integer "max_players", default: 10, null: false
    t.integer "points_to_win", default: 10, null: false
    t.json "settings", default: {}
    t.integer "status", default: 0, null: false
    t.integer "turn_timer", default: 60, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_games_on_code", unique: true
    t.index ["deck_id"], name: "index_games_on_deck_id"
    t.index ["host_id"], name: "index_games_on_host_id"
    t.index ["status"], name: "index_games_on_status"
  end

  create_table "hand_cards", force: :cascade do |t|
    t.integer "card_id", null: false
    t.datetime "created_at", null: false
    t.integer "game_player_id", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_hand_cards_on_card_id"
    t.index ["game_player_id", "card_id"], name: "index_hand_cards_on_game_player_id_and_card_id", unique: true
    t.index ["game_player_id"], name: "index_hand_cards_on_game_player_id"
  end

  create_table "regions", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "emoji_flag"
    t.string "name", null: false
    t.integer "parent_id"
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_regions_on_active_and_position"
    t.index ["code"], name: "index_regions_on_code", unique: true
    t.index ["parent_id"], name: "index_regions_on_parent_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.integer "black_card_id", null: false
    t.datetime "created_at", null: false
    t.integer "game_id", null: false
    t.integer "judge_id", null: false
    t.integer "phase", default: 0, null: false
    t.integer "round_number", default: 1, null: false
    t.datetime "timer_expires_at"
    t.datetime "updated_at", null: false
    t.integer "winner_id"
    t.index ["black_card_id"], name: "index_rounds_on_black_card_id"
    t.index ["game_id", "phase"], name: "index_rounds_on_game_id_and_phase"
    t.index ["game_id", "round_number"], name: "index_rounds_on_game_id_and_round_number", unique: true
    t.index ["game_id"], name: "index_rounds_on_game_id"
    t.index ["judge_id"], name: "index_rounds_on_judge_id"
    t.index ["winner_id"], name: "index_rounds_on_winner_id"
  end

  create_table "submission_cards", force: :cascade do |t|
    t.integer "card_id", null: false
    t.integer "card_submission_id", null: false
    t.datetime "created_at", null: false
    t.integer "play_order", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_submission_cards_on_card_id"
    t.index ["card_submission_id", "play_order"], name: "index_submission_cards_on_card_submission_id_and_play_order"
    t.index ["card_submission_id"], name: "index_submission_cards_on_card_submission_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_name", null: false
    t.string "email"
    t.boolean "is_guest", default: false, null: false
    t.string "password_digest"
    t.string "session_token", null: false
    t.json "stats", default: {}
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true, where: "email IS NOT NULL"
    t.index ["session_token"], name: "index_users_on_session_token", unique: true
  end

  create_table "victory_gifs", force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "source", default: "giphy"
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["category"], name: "index_victory_gifs_on_category"
  end

  add_foreign_key "card_submissions", "game_players", column: "player_id"
  add_foreign_key "card_submissions", "rounds"
  add_foreign_key "cards", "decks"
  add_foreign_key "deck_cards", "cards"
  add_foreign_key "deck_cards", "decks"
  add_foreign_key "deck_votes", "decks"
  add_foreign_key "deck_votes", "users"
  add_foreign_key "decks", "regions"
  add_foreign_key "decks", "users", column: "creator_id"
  add_foreign_key "game_players", "games"
  add_foreign_key "game_players", "users"
  add_foreign_key "games", "decks"
  add_foreign_key "games", "users", column: "host_id"
  add_foreign_key "hand_cards", "cards"
  add_foreign_key "hand_cards", "game_players"
  add_foreign_key "rounds", "cards", column: "black_card_id"
  add_foreign_key "rounds", "game_players", column: "judge_id"
  add_foreign_key "rounds", "game_players", column: "winner_id"
  add_foreign_key "rounds", "games"
  add_foreign_key "submission_cards", "card_submissions"
  add_foreign_key "submission_cards", "cards"
end
