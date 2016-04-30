# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160430050815) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_user_edit_competition", force: :cascade do |t|
    t.integer "user_id"
    t.integer "competition_id"
  end

  add_index "action_user_edit_competition", ["competition_id"], name: "index_action_user_edit_competition_on_competition_id", using: :btree
  add_index "action_user_edit_competition", ["user_id"], name: "index_action_user_edit_competition_on_user_id", using: :btree

  create_table "action_user_edit_competitions", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "action_user_edit_competitions", ["user_id"], name: "index_action_user_edit_competitions_on_user_id", using: :btree

  create_table "action_user_edit_games", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "action_user_edit_games", ["user_id"], name: "index_action_user_edit_games_on_user_id", using: :btree

  create_table "action_user_edit_team", force: :cascade do |t|
    t.integer "user_id"
    t.integer "team_id"
  end

  add_index "action_user_edit_team", ["team_id"], name: "index_action_user_edit_team_on_team_id", using: :btree
  add_index "action_user_edit_team", ["user_id"], name: "index_action_user_edit_team_on_user_id", using: :btree

  create_table "action_user_edit_teams", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "action_user_edit_teams", ["user_id"], name: "index_action_user_edit_teams_on_user_id", using: :btree

  create_table "action_user_edit_users", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "action_user_edit_users", ["user_id"], name: "index_action_user_edit_users_on_user_id", using: :btree

  create_table "action_user_manage_rosters_competition", force: :cascade do |t|
    t.integer "user_id"
    t.integer "competition_id"
  end

  add_index "action_user_manage_rosters_competition", ["competition_id"], name: "index_action_user_manage_rosters_competition_on_competition_id", using: :btree
  add_index "action_user_manage_rosters_competition", ["user_id"], name: "index_action_user_manage_rosters_competition_on_user_id", using: :btree

  create_table "action_user_manage_rosters_competitions", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "action_user_manage_rosters_competitions", ["user_id"], name: "index_action_user_manage_rosters_competitions_on_user_id", using: :btree

  create_table "competition_match_comms", force: :cascade do |t|
    t.integer  "competition_match_id"
    t.integer  "user_id"
    t.text     "content",              null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "competition_match_comms", ["competition_match_id"], name: "index_competition_match_comms_on_competition_match_id", using: :btree
  add_index "competition_match_comms", ["user_id"], name: "index_competition_match_comms_on_user_id", using: :btree

  create_table "competition_matches", force: :cascade do |t|
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.integer  "status",       null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "competition_matches", ["away_team_id"], name: "index_competition_matches_on_away_team_id", using: :btree
  add_index "competition_matches", ["home_team_id"], name: "index_competition_matches_on_home_team_id", using: :btree

  create_table "competition_rosters", force: :cascade do |t|
    t.integer  "team_id",                     null: false
    t.integer  "division_id",                 null: false
    t.boolean  "approved",    default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "name",                        null: false
    t.text     "description",                 null: false
  end

  add_index "competition_rosters", ["division_id"], name: "index_competition_rosters_on_division_id", using: :btree
  add_index "competition_rosters", ["team_id"], name: "index_competition_rosters_on_team_id", using: :btree

  create_table "competition_sets", force: :cascade do |t|
    t.integer  "competition_match_id"
    t.integer  "map_id"
    t.integer  "home_team_score",      null: false
    t.integer  "away_team_score",      null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "competition_sets", ["competition_match_id"], name: "index_competition_sets_on_competition_match_id", using: :btree
  add_index "competition_sets", ["map_id"], name: "index_competition_sets_on_map_id", using: :btree

  create_table "competition_transfers", force: :cascade do |t|
    t.integer  "competition_roster_id",                 null: false
    t.integer  "user_id",                               null: false
    t.boolean  "is_joining",                            null: false
    t.boolean  "approved",              default: false, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "competition_transfers", ["competition_roster_id"], name: "index_competition_transfers_on_competition_roster_id", using: :btree
  add_index "competition_transfers", ["user_id"], name: "index_competition_transfers_on_user_id", using: :btree

  create_table "competitions", force: :cascade do |t|
    t.integer  "format_id"
    t.string   "name",                                null: false
    t.text     "description",                         null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "private",                             null: false
    t.boolean  "signuppable",         default: false, null: false
    t.boolean  "roster_locked",       default: false, null: false
    t.integer  "min_players",         default: 6,     null: false
    t.integer  "max_players",         default: 0,     null: false
    t.boolean  "matches_submittable", default: false, null: false
  end

  add_index "competitions", ["format_id"], name: "index_competitions_on_format_id", using: :btree

  create_table "divisions", force: :cascade do |t|
    t.integer  "competition_id"
    t.string   "name",           null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "divisions", ["competition_id"], name: "index_divisions_on_competition_id", using: :btree

  create_table "formats", force: :cascade do |t|
    t.integer  "game_id"
    t.string   "name",         null: false
    t.text     "description",  null: false
    t.integer  "player_count", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "formats", ["game_id"], name: "index_formats_on_game_id", using: :btree
  add_index "formats", ["name"], name: "index_formats_on_name", unique: true, using: :btree

  create_table "games", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "games", ["name"], name: "index_games_on_name", unique: true, using: :btree

  create_table "maps", force: :cascade do |t|
    t.integer  "game_id"
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "maps", ["game_id"], name: "index_maps_on_game_id", using: :btree

  create_table "team_invites", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "team_invites", ["team_id"], name: "index_team_invites_on_team_id", using: :btree
  add_index "team_invites", ["user_id"], name: "index_team_invites_on_user_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "avatar"
  end

  add_index "teams", ["name"], name: "index_teams_on_name", unique: true, using: :btree

  create_table "titles", force: :cascade do |t|
    t.integer "user_id"
    t.integer "competition_id"
    t.integer "competition_roster_id"
    t.string  "name",                  null: false
  end

  add_index "titles", ["competition_id"], name: "index_titles_on_competition_id", using: :btree
  add_index "titles", ["competition_roster_id"], name: "index_titles_on_competition_roster_id", using: :btree
  add_index "titles", ["user_id"], name: "index_titles_on_user_id", using: :btree

  create_table "transfers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.boolean  "is_joining", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "transfers", ["team_id"], name: "index_transfers_on_team_id", using: :btree
  add_index "transfers", ["user_id"], name: "index_transfers_on_user_id", using: :btree

  create_table "user_name_changes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "approved_by_id"
    t.integer  "denied_by_id"
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "user_name_changes", ["approved_by_id"], name: "index_user_name_changes_on_approved_by_id", using: :btree
  add_index "user_name_changes", ["denied_by_id"], name: "index_user_name_changes_on_denied_by_id", using: :btree
  add_index "user_name_changes", ["user_id"], name: "index_user_name_changes_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                                       null: false
    t.integer  "steam_id",            limit: 8,              null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.text     "description",                   default: "", null: false
    t.string   "remember_token"
    t.string   "avatar"
  end

  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["steam_id"], name: "index_users_on_steam_id", unique: true, using: :btree

  add_foreign_key "action_user_edit_competition", "competitions"
  add_foreign_key "action_user_edit_competition", "users"
  add_foreign_key "action_user_edit_competitions", "users"
  add_foreign_key "action_user_edit_games", "users"
  add_foreign_key "action_user_edit_team", "teams"
  add_foreign_key "action_user_edit_team", "users"
  add_foreign_key "action_user_edit_teams", "users"
  add_foreign_key "action_user_edit_users", "users"
  add_foreign_key "action_user_manage_rosters_competition", "competitions"
  add_foreign_key "action_user_manage_rosters_competition", "users"
  add_foreign_key "action_user_manage_rosters_competitions", "users"
  add_foreign_key "competition_match_comms", "competition_matches"
  add_foreign_key "competition_match_comms", "users"
  add_foreign_key "competition_matches", "competition_rosters", column: "away_team_id"
  add_foreign_key "competition_matches", "competition_rosters", column: "home_team_id"
  add_foreign_key "competition_rosters", "divisions"
  add_foreign_key "competition_rosters", "teams"
  add_foreign_key "competition_sets", "competition_matches"
  add_foreign_key "competition_sets", "maps"
  add_foreign_key "competition_transfers", "competition_rosters"
  add_foreign_key "competition_transfers", "users"
  add_foreign_key "competitions", "formats"
  add_foreign_key "divisions", "competitions"
  add_foreign_key "formats", "games"
  add_foreign_key "maps", "games"
  add_foreign_key "team_invites", "teams"
  add_foreign_key "team_invites", "users"
  add_foreign_key "titles", "competition_rosters"
  add_foreign_key "titles", "competitions"
  add_foreign_key "titles", "users"
  add_foreign_key "transfers", "teams"
  add_foreign_key "transfers", "users"
  add_foreign_key "user_name_changes", "users"
  add_foreign_key "user_name_changes", "users", column: "approved_by_id"
  add_foreign_key "user_name_changes", "users", column: "denied_by_id"
end
