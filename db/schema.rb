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

ActiveRecord::Schema.define(version: 20160808090417) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_user_edit_games", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "action_user_edit_games", ["user_id"], name: "index_action_user_edit_games_on_user_id", using: :btree

  create_table "action_user_edit_league", force: :cascade do |t|
    t.integer "user_id"
    t.integer "league_id"
  end

  add_index "action_user_edit_league", ["league_id"], name: "index_action_user_edit_league_on_league_id", using: :btree
  add_index "action_user_edit_league", ["user_id"], name: "index_action_user_edit_league_on_user_id", using: :btree

  create_table "action_user_edit_leagues", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "action_user_edit_leagues", ["user_id"], name: "index_action_user_edit_leagues_on_user_id", using: :btree

  create_table "action_user_edit_permissions", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "action_user_edit_permissions", ["user_id"], name: "index_action_user_edit_permissions_on_user_id", using: :btree

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

  create_table "action_user_manage_rosters_league", force: :cascade do |t|
    t.integer "user_id"
    t.integer "league_id"
  end

  add_index "action_user_manage_rosters_league", ["league_id"], name: "index_action_user_manage_rosters_league_on_league_id", using: :btree
  add_index "action_user_manage_rosters_league", ["user_id"], name: "index_action_user_manage_rosters_league_on_user_id", using: :btree

  create_table "action_user_manage_rosters_leagues", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "action_user_manage_rosters_leagues", ["user_id"], name: "index_action_user_manage_rosters_leagues_on_user_id", using: :btree

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

  create_table "league_divisions", force: :cascade do |t|
    t.integer  "league_id"
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "league_divisions", ["league_id"], name: "index_league_divisions_on_league_id", using: :btree

  create_table "league_match_comms", force: :cascade do |t|
    t.integer  "match_id"
    t.integer  "user_id"
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "league_match_comms", ["match_id"], name: "index_league_match_comms_on_match_id", using: :btree
  add_index "league_match_comms", ["user_id"], name: "index_league_match_comms_on_user_id", using: :btree

  create_table "league_match_rounds", force: :cascade do |t|
    t.integer  "match_id"
    t.integer  "map_id"
    t.integer  "home_team_score", null: false
    t.integer  "away_team_score", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "league_match_rounds", ["map_id"], name: "index_league_match_rounds_on_map_id", using: :btree
  add_index "league_match_rounds", ["match_id"], name: "index_league_match_rounds_on_match_id", using: :btree

  create_table "league_matches", force: :cascade do |t|
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.integer  "status",                   null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "forfeit_by",   default: 0, null: false
    t.integer  "round"
  end

  add_index "league_matches", ["away_team_id"], name: "index_league_matches_on_away_team_id", using: :btree
  add_index "league_matches", ["home_team_id"], name: "index_league_matches_on_home_team_id", using: :btree

  create_table "league_roster_comments", force: :cascade do |t|
    t.integer  "roster_id",  null: false
    t.integer  "user_id"
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "league_roster_comments", ["roster_id"], name: "index_league_roster_comments_on_roster_id", using: :btree
  add_index "league_roster_comments", ["user_id"], name: "index_league_roster_comments_on_user_id", using: :btree

  create_table "league_roster_transfers", force: :cascade do |t|
    t.integer  "roster_id",                  null: false
    t.integer  "user_id",                    null: false
    t.boolean  "is_joining",                 null: false
    t.boolean  "approved",   default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "league_roster_transfers", ["roster_id"], name: "index_league_roster_transfers_on_roster_id", using: :btree
  add_index "league_roster_transfers", ["user_id"], name: "index_league_roster_transfers_on_user_id", using: :btree

  create_table "league_rosters", force: :cascade do |t|
    t.integer  "team_id",                                    null: false
    t.integer  "division_id",                                null: false
    t.boolean  "approved",                   default: false, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "name",                                       null: false
    t.text     "description",                                null: false
    t.boolean  "disbanded",                  default: false, null: false
    t.integer  "ranking"
    t.integer  "seeding"
    t.integer  "won_rounds_count",           default: 0,     null: false
    t.integer  "drawn_rounds_count",         default: 0,     null: false
    t.integer  "lost_rounds_count",          default: 0,     null: false
    t.integer  "forfeit_won_matches_count",  default: 0,     null: false
    t.integer  "forfeit_lost_matches_count", default: 0,     null: false
    t.integer  "points",                     default: 0,     null: false
    t.integer  "total_scores",               default: 0,     null: false
  end

  add_index "league_rosters", ["division_id"], name: "index_league_rosters_on_division_id", using: :btree
  add_index "league_rosters", ["team_id"], name: "index_league_rosters_on_team_id", using: :btree

  create_table "league_tiebreakers", force: :cascade do |t|
    t.integer "league_id"
    t.integer "kind",      null: false
  end

  add_index "league_tiebreakers", ["league_id"], name: "index_league_tiebreakers_on_league_id", using: :btree

  create_table "leagues", force: :cascade do |t|
    t.integer  "format_id"
    t.string   "name",                                          null: false
    t.text     "description",                                   null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "signuppable",                   default: false, null: false
    t.boolean  "roster_locked",                 default: false, null: false
    t.integer  "min_players",                   default: 6,     null: false
    t.integer  "max_players",                   default: 0,     null: false
    t.boolean  "matches_submittable",           default: false, null: false
    t.boolean  "transfers_require_approval",    default: true,  null: false
    t.integer  "points_per_round_won",          default: 2,     null: false
    t.integer  "points_per_round_drawn",        default: 1,     null: false
    t.integer  "points_per_round_lost",         default: 0,     null: false
    t.integer  "points_per_match_forfeit_loss", default: 1,     null: false
    t.integer  "points_per_match_forfeit_win",  default: 1,     null: false
    t.boolean  "allow_round_draws",             default: true,  null: false
    t.boolean  "allow_disbanding",              default: false, null: false
    t.integer  "status",                        default: 0,     null: false
    t.integer  "rosters_count",                 default: 0,     null: false
  end

  add_index "leagues", ["format_id"], name: "index_leagues_on_format_id", using: :btree

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

  create_table "team_transfers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.boolean  "is_joining", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "team_transfers", ["team_id"], name: "index_team_transfers_on_team_id", using: :btree
  add_index "team_transfers", ["user_id"], name: "index_team_transfers_on_user_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "avatar"
  end

  add_index "teams", ["name"], name: "index_teams_on_name", unique: true, using: :btree

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

  create_table "user_notifications", force: :cascade do |t|
    t.integer  "user_id",                    null: false
    t.boolean  "read",       default: false, null: false
    t.string   "message",                    null: false
    t.string   "link",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "user_notifications", ["user_id"], name: "index_user_notifications_on_user_id", using: :btree

  create_table "user_titles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "league_id"
    t.integer  "roster_id"
    t.string   "name",       null: false
    t.string   "badge"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_titles", ["league_id"], name: "index_user_titles_on_league_id", using: :btree
  add_index "user_titles", ["roster_id"], name: "index_user_titles_on_roster_id", using: :btree
  add_index "user_titles", ["user_id"], name: "index_user_titles_on_user_id", using: :btree

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

  add_foreign_key "action_user_edit_games", "users"
  add_foreign_key "action_user_edit_league", "leagues"
  add_foreign_key "action_user_edit_league", "users"
  add_foreign_key "action_user_edit_leagues", "users"
  add_foreign_key "action_user_edit_permissions", "users"
  add_foreign_key "action_user_edit_team", "teams"
  add_foreign_key "action_user_edit_team", "users"
  add_foreign_key "action_user_edit_teams", "users"
  add_foreign_key "action_user_edit_users", "users"
  add_foreign_key "action_user_manage_rosters_league", "leagues"
  add_foreign_key "action_user_manage_rosters_league", "users"
  add_foreign_key "action_user_manage_rosters_leagues", "users"
  add_foreign_key "formats", "games"
  add_foreign_key "league_divisions", "leagues"
  add_foreign_key "league_match_comms", "league_matches", column: "match_id"
  add_foreign_key "league_match_comms", "users"
  add_foreign_key "league_match_rounds", "league_matches", column: "match_id"
  add_foreign_key "league_match_rounds", "maps"
  add_foreign_key "league_matches", "league_rosters", column: "away_team_id"
  add_foreign_key "league_matches", "league_rosters", column: "home_team_id"
  add_foreign_key "league_roster_comments", "league_rosters", column: "roster_id"
  add_foreign_key "league_roster_comments", "users"
  add_foreign_key "league_roster_transfers", "league_rosters", column: "roster_id"
  add_foreign_key "league_roster_transfers", "users"
  add_foreign_key "league_rosters", "league_divisions", column: "division_id"
  add_foreign_key "league_rosters", "teams"
  add_foreign_key "league_tiebreakers", "leagues"
  add_foreign_key "leagues", "formats"
  add_foreign_key "maps", "games"
  add_foreign_key "team_invites", "teams"
  add_foreign_key "team_invites", "users"
  add_foreign_key "team_transfers", "teams"
  add_foreign_key "team_transfers", "users"
  add_foreign_key "user_name_changes", "users"
  add_foreign_key "user_name_changes", "users", column: "approved_by_id"
  add_foreign_key "user_name_changes", "users", column: "denied_by_id"
  add_foreign_key "user_notifications", "users"
  add_foreign_key "user_titles", "league_rosters", column: "roster_id"
  add_foreign_key "user_titles", "leagues"
  add_foreign_key "user_titles", "users"
end
