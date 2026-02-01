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

ActiveRecord::Schema[8.1].define(version: 2026_02_01_210001) do
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

  create_table "dare_cards", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "intensity", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["intensity"], name: "index_dare_cards_on_intensity"
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

  create_table "kings_cup_cards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "drawn", default: false, null: false
    t.datetime "drawn_at"
    t.integer "drawn_by_id"
    t.integer "kings_cup_game_id", null: false
    t.string "suit", limit: 10, null: false
    t.datetime "updated_at", null: false
    t.string "value", limit: 5, null: false
    t.index ["drawn_by_id"], name: "index_kings_cup_cards_on_drawn_by_id"
    t.index ["kings_cup_game_id", "drawn"], name: "index_kings_cup_cards_on_kings_cup_game_id_and_drawn"
    t.index ["kings_cup_game_id", "suit", "value"], name: "index_kings_cup_cards_on_kings_cup_game_id_and_suit_and_value", unique: true
    t.index ["kings_cup_game_id"], name: "index_kings_cup_cards_on_kings_cup_game_id"
  end

  create_table "kings_cup_games", force: :cascade do |t|
    t.string "code", limit: 6, null: false
    t.datetime "created_at", null: false
    t.integer "current_player_index", default: 0, null: false
    t.json "custom_rules", default: {}
    t.integer "host_id", null: false
    t.integer "kings_drawn", default: 0, null: false
    t.integer "max_players", default: 10, null: false
    t.json "settings", default: {}
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_kings_cup_games_on_code", unique: true
    t.index ["host_id"], name: "index_kings_cup_games_on_host_id"
    t.index ["status"], name: "index_kings_cup_games_on_status"
  end

  create_table "kings_cup_players", force: :cascade do |t|
    t.datetime "connected_at"
    t.datetime "created_at", null: false
    t.datetime "disconnected_at"
    t.boolean "is_question_master", default: false, null: false
    t.integer "kings_cup_game_id", null: false
    t.integer "mate_player_id"
    t.integer "position"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["kings_cup_game_id", "status"], name: "index_kings_cup_players_on_kings_cup_game_id_and_status"
    t.index ["kings_cup_game_id", "user_id"], name: "index_kings_cup_players_on_kings_cup_game_id_and_user_id", unique: true
    t.index ["kings_cup_game_id"], name: "index_kings_cup_players_on_kings_cup_game_id"
    t.index ["user_id"], name: "index_kings_cup_players_on_user_id"
  end

  create_table "kings_cup_rules", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.integer "kings_cup_game_id", null: false
    t.text "rule_text", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_kings_cup_rules_on_created_by_id"
    t.index ["kings_cup_game_id", "active"], name: "index_kings_cup_rules_on_kings_cup_game_id_and_active"
    t.index ["kings_cup_game_id"], name: "index_kings_cup_rules_on_kings_cup_game_id"
  end

  create_table "most_likely_to_cards", force: :cascade do |t|
    t.string "category", default: "general"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "times_played", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_most_likely_to_cards_on_category"
  end

  create_table "most_likely_to_games", force: :cascade do |t|
    t.string "code", limit: 6, null: false
    t.datetime "created_at", null: false
    t.integer "current_card_id"
    t.integer "current_round", default: 0, null: false
    t.integer "host_id", null: false
    t.integer "max_players", default: 10, null: false
    t.string "phase", default: "waiting"
    t.integer "status", default: 0, null: false
    t.integer "total_rounds", default: 10, null: false
    t.datetime "updated_at", null: false
    t.json "used_card_ids", default: []
    t.index ["code"], name: "index_most_likely_to_games_on_code", unique: true
    t.index ["current_card_id"], name: "index_most_likely_to_games_on_current_card_id"
    t.index ["host_id"], name: "index_most_likely_to_games_on_host_id"
    t.index ["status"], name: "index_most_likely_to_games_on_status"
  end

  create_table "most_likely_to_players", force: :cascade do |t|
    t.datetime "connected_at"
    t.datetime "created_at", null: false
    t.datetime "disconnected_at"
    t.integer "drinks", default: 0, null: false
    t.integer "most_likely_to_game_id", null: false
    t.integer "position"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["most_likely_to_game_id", "status"], name: "idx_mlt_players_game_status"
    t.index ["most_likely_to_game_id", "user_id"], name: "idx_mlt_players_game_user", unique: true
    t.index ["most_likely_to_game_id"], name: "index_most_likely_to_players_on_most_likely_to_game_id"
    t.index ["user_id"], name: "index_most_likely_to_players_on_user_id"
  end

  create_table "most_likely_to_votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "most_likely_to_game_id", null: false
    t.integer "round_number", null: false
    t.datetime "updated_at", null: false
    t.integer "voted_for_id", null: false
    t.integer "voter_id", null: false
    t.index ["most_likely_to_game_id", "round_number", "voter_id"], name: "idx_mlt_votes_unique_per_round", unique: true
    t.index ["most_likely_to_game_id", "round_number"], name: "idx_mlt_votes_round"
    t.index ["most_likely_to_game_id"], name: "index_most_likely_to_votes_on_most_likely_to_game_id"
    t.index ["voted_for_id"], name: "index_most_likely_to_votes_on_voted_for_id"
    t.index ["voter_id"], name: "index_most_likely_to_votes_on_voter_id"
  end

  create_table "never_have_i_ever_cards", force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_never_have_i_ever_cards_on_category"
  end

  create_table "never_have_i_ever_games", force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.string "code", limit: 6, null: false
    t.datetime "created_at", null: false
    t.integer "current_card_id"
    t.integer "current_reader_position"
    t.integer "host_id", null: false
    t.integer "max_players", default: 10, null: false
    t.integer "starting_points", default: 3, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_never_have_i_ever_games_on_code", unique: true
    t.index ["host_id"], name: "index_never_have_i_ever_games_on_host_id"
    t.index ["status"], name: "index_never_have_i_ever_games_on_status"
  end

  create_table "never_have_i_ever_players", force: :cascade do |t|
    t.datetime "connected_at"
    t.datetime "created_at", null: false
    t.datetime "disconnected_at"
    t.boolean "drank_this_round", default: false
    t.integer "never_have_i_ever_game_id", null: false
    t.integer "points", default: 3, null: false
    t.integer "position"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["never_have_i_ever_game_id", "status"], name: "idx_nhie_players_game_status"
    t.index ["never_have_i_ever_game_id", "user_id"], name: "idx_nhie_players_game_user", unique: true
    t.index ["never_have_i_ever_game_id"], name: "index_never_have_i_ever_players_on_never_have_i_ever_game_id"
    t.index ["user_id"], name: "index_never_have_i_ever_players_on_user_id"
  end

  create_table "never_have_i_ever_used_cards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "never_have_i_ever_card_id", null: false
    t.integer "never_have_i_ever_game_id", null: false
    t.datetime "updated_at", null: false
    t.index ["never_have_i_ever_card_id"], name: "idx_on_never_have_i_ever_card_id_f2ddf6f5a4"
    t.index ["never_have_i_ever_game_id", "never_have_i_ever_card_id"], name: "idx_nhie_used_cards_game_card", unique: true
    t.index ["never_have_i_ever_game_id"], name: "idx_on_never_have_i_ever_game_id_6a57e0a78b"
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

  create_table "truth_cards", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "intensity", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["intensity"], name: "index_truth_cards_on_intensity"
  end

  create_table "truth_or_dare_games", force: :cascade do |t|
    t.string "code", limit: 6, null: false
    t.datetime "created_at", null: false
    t.integer "current_player_index", default: 0, null: false
    t.integer "host_id", null: false
    t.integer "intensity_level", default: 0, null: false
    t.integer "max_players", default: 10, null: false
    t.json "settings", default: {}
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.json "used_dare_ids", default: []
    t.json "used_truth_ids", default: []
    t.index ["code"], name: "index_truth_or_dare_games_on_code", unique: true
    t.index ["host_id"], name: "index_truth_or_dare_games_on_host_id"
    t.index ["status"], name: "index_truth_or_dare_games_on_status"
  end

  create_table "truth_or_dare_players", force: :cascade do |t|
    t.datetime "connected_at"
    t.datetime "created_at", null: false
    t.integer "dares_completed", default: 0, null: false
    t.datetime "disconnected_at"
    t.integer "drinks_taken", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "truth_or_dare_game_id", null: false
    t.integer "truths_completed", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["truth_or_dare_game_id", "status"], name: "idx_tod_players_game_status"
    t.index ["truth_or_dare_game_id", "user_id"], name: "idx_tod_players_game_user", unique: true
    t.index ["truth_or_dare_game_id"], name: "index_truth_or_dare_players_on_truth_or_dare_game_id"
    t.index ["user_id"], name: "index_truth_or_dare_players_on_user_id"
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

  create_table "would_you_rather_cards", force: :cascade do |t|
    t.string "category", default: "general"
    t.datetime "created_at", null: false
    t.text "option_a", null: false
    t.integer "option_a_wins", default: 0
    t.text "option_b", null: false
    t.integer "option_b_wins", default: 0
    t.integer "times_played", default: 0
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_would_you_rather_cards_on_category"
  end

  create_table "would_you_rather_games", force: :cascade do |t|
    t.string "code", limit: 6, null: false
    t.datetime "created_at", null: false
    t.integer "current_card_id"
    t.integer "current_round", default: 0
    t.integer "host_id", null: false
    t.integer "max_rounds", default: 10
    t.string "phase", default: "waiting"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.datetime "voting_ends_at"
    t.index ["code"], name: "index_would_you_rather_games_on_code", unique: true
    t.index ["current_card_id"], name: "index_would_you_rather_games_on_current_card_id"
    t.index ["host_id"], name: "index_would_you_rather_games_on_host_id"
    t.index ["status"], name: "index_would_you_rather_games_on_status"
  end

  create_table "would_you_rather_players", force: :cascade do |t|
    t.datetime "connected_at"
    t.datetime "created_at", null: false
    t.integer "current_streak", default: 0
    t.integer "drinks_taken", default: 0
    t.boolean "is_host", default: false
    t.integer "max_streak", default: 0
    t.integer "status", default: 0
    t.integer "times_in_minority", default: 0
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "would_you_rather_game_id", null: false
    t.index ["user_id"], name: "index_would_you_rather_players_on_user_id"
    t.index ["would_you_rather_game_id", "user_id"], name: "idx_wyr_players_game_user", unique: true
    t.index ["would_you_rather_game_id"], name: "index_would_you_rather_players_on_would_you_rather_game_id"
  end

  create_table "would_you_rather_votes", force: :cascade do |t|
    t.string "choice", null: false
    t.datetime "created_at", null: false
    t.integer "round_number", null: false
    t.datetime "updated_at", null: false
    t.integer "would_you_rather_card_id", null: false
    t.integer "would_you_rather_game_id", null: false
    t.integer "would_you_rather_player_id", null: false
    t.index ["would_you_rather_card_id"], name: "index_would_you_rather_votes_on_would_you_rather_card_id"
    t.index ["would_you_rather_game_id", "round_number"], name: "idx_wyr_votes_game_round"
    t.index ["would_you_rather_game_id", "would_you_rather_player_id", "round_number"], name: "idx_wyr_votes_unique_per_round", unique: true
    t.index ["would_you_rather_game_id"], name: "index_would_you_rather_votes_on_would_you_rather_game_id"
    t.index ["would_you_rather_player_id"], name: "index_would_you_rather_votes_on_would_you_rather_player_id"
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
  add_foreign_key "kings_cup_cards", "kings_cup_games"
  add_foreign_key "kings_cup_cards", "kings_cup_players", column: "drawn_by_id"
  add_foreign_key "kings_cup_games", "users", column: "host_id"
  add_foreign_key "kings_cup_players", "kings_cup_games"
  add_foreign_key "kings_cup_players", "users"
  add_foreign_key "kings_cup_rules", "kings_cup_games"
  add_foreign_key "kings_cup_rules", "kings_cup_players", column: "created_by_id"
  add_foreign_key "most_likely_to_games", "most_likely_to_cards", column: "current_card_id"
  add_foreign_key "most_likely_to_games", "users", column: "host_id"
  add_foreign_key "most_likely_to_players", "most_likely_to_games"
  add_foreign_key "most_likely_to_players", "users"
  add_foreign_key "most_likely_to_votes", "most_likely_to_games"
  add_foreign_key "most_likely_to_votes", "most_likely_to_players", column: "voted_for_id"
  add_foreign_key "most_likely_to_votes", "most_likely_to_players", column: "voter_id"
  add_foreign_key "never_have_i_ever_games", "never_have_i_ever_cards", column: "current_card_id"
  add_foreign_key "never_have_i_ever_games", "users", column: "host_id"
  add_foreign_key "never_have_i_ever_players", "never_have_i_ever_games"
  add_foreign_key "never_have_i_ever_players", "users"
  add_foreign_key "never_have_i_ever_used_cards", "never_have_i_ever_cards"
  add_foreign_key "never_have_i_ever_used_cards", "never_have_i_ever_games"
  add_foreign_key "rounds", "cards", column: "black_card_id"
  add_foreign_key "rounds", "game_players", column: "judge_id"
  add_foreign_key "rounds", "game_players", column: "winner_id"
  add_foreign_key "rounds", "games"
  add_foreign_key "submission_cards", "card_submissions"
  add_foreign_key "submission_cards", "cards"
  add_foreign_key "truth_or_dare_games", "users", column: "host_id"
  add_foreign_key "truth_or_dare_players", "truth_or_dare_games"
  add_foreign_key "truth_or_dare_players", "users"
  add_foreign_key "would_you_rather_games", "users", column: "host_id"
  add_foreign_key "would_you_rather_games", "would_you_rather_cards", column: "current_card_id"
  add_foreign_key "would_you_rather_players", "users"
  add_foreign_key "would_you_rather_players", "would_you_rather_games"
  add_foreign_key "would_you_rather_votes", "would_you_rather_cards"
  add_foreign_key "would_you_rather_votes", "would_you_rather_games"
  add_foreign_key "would_you_rather_votes", "would_you_rather_players"
end
