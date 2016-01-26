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

ActiveRecord::Schema.define(version: 20160126020551) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "formats", force: :cascade do |t|
    t.integer  "game_id",      null: false
    t.string   "name",         null: false
    t.text     "description",  null: false
    t.integer  "player_count", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "formats", ["name"], name: "index_formats_on_name", unique: true, using: :btree

  create_table "games", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "games", ["name"], name: "index_games_on_name", unique: true, using: :btree

  create_table "teams", force: :cascade do |t|
    t.integer  "format_id",   null: false
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "teams", ["name"], name: "index_teams_on_name", unique: true, using: :btree

  create_table "transfers", force: :cascade do |t|
    t.integer  "user_id",     null: false
    t.integer  "team_id",     null: false
    t.boolean  "is_joining?", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                                      null: false
    t.integer  "steam_id",            limit: 8,             null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["steam_id"], name: "index_users_on_steam_id", unique: true, using: :btree

end
