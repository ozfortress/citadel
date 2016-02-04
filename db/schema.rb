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

ActiveRecord::Schema.define(version: 20160204063841) do

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

  create_table "competitions", force: :cascade do |t|
    t.integer  "format_id"
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "private",     null: false
  end

  add_index "competitions", ["format_id"], name: "index_competitions_on_format_id", using: :btree

  create_table "divisions", force: :cascade do |t|
    t.integer  "competition_id"
    t.string   "name",           null: false
    t.text     "description",    null: false
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
  end

  add_index "teams", ["name"], name: "index_teams_on_name", unique: true, using: :btree

  create_table "transfers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.boolean  "is_joining?", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "transfers", ["team_id"], name: "index_transfers_on_team_id", using: :btree
  add_index "transfers", ["user_id"], name: "index_transfers_on_user_id", using: :btree

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
  add_foreign_key "competitions", "formats"
  add_foreign_key "divisions", "competitions"
  add_foreign_key "formats", "games"
  add_foreign_key "team_invites", "teams"
  add_foreign_key "team_invites", "users"
  add_foreign_key "transfers", "teams"
  add_foreign_key "transfers", "users"
end
