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

ActiveRecord::Schema.define(version: 20170114040917) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "action_user_edit_forums_thread", force: :cascade do |t|
    t.integer "user_id"
    t.integer "forums_thread_id"
    t.index ["forums_thread_id"], name: "index_action_user_edit_forums_thread_on_forums_thread_id", using: :btree
    t.index ["user_id"], name: "index_action_user_edit_forums_thread_on_user_id", using: :btree
  end

  create_table "action_user_edit_games", force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_edit_games_on_user_id", using: :btree
  end

  create_table "action_user_edit_league", force: :cascade do |t|
    t.integer "user_id"
    t.integer "league_id"
    t.index ["league_id"], name: "index_action_user_edit_league_on_league_id", using: :btree
    t.index ["user_id"], name: "index_action_user_edit_league_on_user_id", using: :btree
  end

  create_table "action_user_edit_leagues", force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_edit_leagues_on_user_id", using: :btree
  end

  create_table "action_user_edit_permissions", force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_edit_permissions_on_user_id", using: :btree
  end

  create_table "action_user_edit_team", force: :cascade do |t|
    t.integer "user_id"
    t.integer "team_id"
    t.index ["team_id"], name: "index_action_user_edit_team_on_team_id", using: :btree
    t.index ["user_id"], name: "index_action_user_edit_team_on_user_id", using: :btree
  end

  create_table "action_user_edit_teams", force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_edit_teams_on_user_id", using: :btree
  end

  create_table "action_user_edit_users", force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_edit_users_on_user_id", using: :btree
  end

  create_table "action_user_manage_forums", force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_manage_forums_on_user_id", using: :btree
  end

  create_table "action_user_manage_forums_thread", force: :cascade do |t|
    t.integer "user_id"
    t.integer "forums_thread_id"
    t.index ["forums_thread_id"], name: "index_action_user_manage_forums_thread_on_forums_thread_id", using: :btree
    t.index ["user_id"], name: "index_action_user_manage_forums_thread_on_user_id", using: :btree
  end

  create_table "action_user_manage_forums_topic", force: :cascade do |t|
    t.integer "user_id"
    t.integer "forums_topic_id"
    t.index ["forums_topic_id"], name: "index_action_user_manage_forums_topic_on_forums_topic_id", using: :btree
    t.index ["user_id"], name: "index_action_user_manage_forums_topic_on_user_id", using: :btree
  end

  create_table "action_user_manage_rosters_league", force: :cascade do |t|
    t.integer "user_id"
    t.integer "league_id"
    t.index ["league_id"], name: "index_action_user_manage_rosters_league_on_league_id", using: :btree
    t.index ["user_id"], name: "index_action_user_manage_rosters_league_on_user_id", using: :btree
  end

  create_table "action_user_manage_rosters_leagues", force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_manage_rosters_leagues_on_user_id", using: :btree
  end

  create_table "action_user_use_forums_bans", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "terminated_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["user_id"], name: "index_action_user_use_forums_bans_on_user_id", using: :btree
  end

  create_table "action_user_use_forums_thread_bans", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "forums_thread_id"
    t.datetime "terminated_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["forums_thread_id"], name: "index_action_user_use_forums_thread_bans_on_forums_thread_id", using: :btree
    t.index ["user_id"], name: "index_action_user_use_forums_thread_bans_on_user_id", using: :btree
  end

  create_table "action_user_use_forums_topic_bans", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "forums_topic_id"
    t.datetime "terminated_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["forums_topic_id"], name: "index_action_user_use_forums_topic_bans_on_forums_topic_id", using: :btree
    t.index ["user_id"], name: "index_action_user_use_forums_topic_bans_on_user_id", using: :btree
  end

  create_table "action_user_use_leagues_bans", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "terminated_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["user_id"], name: "index_action_user_use_leagues_bans_on_user_id", using: :btree
  end

  create_table "action_user_use_teams_bans", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "terminated_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["user_id"], name: "index_action_user_use_teams_bans_on_user_id", using: :btree
  end

  create_table "action_user_use_users_bans", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "terminated_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["user_id"], name: "index_action_user_use_users_bans_on_user_id", using: :btree
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.integer  "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "method"
    t.string   "ip"
    t.string   "uri"
    t.json     "properties"
    t.datetime "time"
    t.index ["ip"], name: "index_ahoy_events_on_ip", using: :btree
    t.index ["method"], name: "index_ahoy_events_on_method", using: :btree
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time", using: :btree
    t.index ["uri"], name: "index_ahoy_events_on_uri", using: :btree
    t.index ["user_id", "name"], name: "index_ahoy_events_on_user_id_and_name", using: :btree
    t.index ["visit_id", "name"], name: "index_ahoy_events_on_visit_id_and_name", using: :btree
  end

  create_table "formats", force: :cascade do |t|
    t.integer  "game_id"
    t.string   "name",         null: false
    t.text     "description",  null: false
    t.integer  "player_count", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["game_id"], name: "index_formats_on_game_id", using: :btree
    t.index ["name"], name: "index_formats_on_name", unique: true, using: :btree
  end

  create_table "forums_post_edits", force: :cascade do |t|
    t.integer  "post_id",       null: false
    t.integer  "created_by_id", null: false
    t.string   "content",       null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["created_by_id"], name: "index_forums_post_edits_on_created_by_id", using: :btree
    t.index ["post_id"], name: "index_forums_post_edits_on_post_id", using: :btree
  end

  create_table "forums_posts", force: :cascade do |t|
    t.integer  "thread_id",     null: false
    t.integer  "created_by_id", null: false
    t.string   "content",       null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["created_by_id"], name: "index_forums_posts_on_created_by_id", using: :btree
    t.index ["thread_id"], name: "index_forums_posts_on_thread_id", using: :btree
  end

  create_table "forums_subscriptions", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "topic_id"
    t.integer  "thread_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thread_id"], name: "index_forums_subscriptions_on_thread_id", using: :btree
    t.index ["topic_id"], name: "index_forums_subscriptions_on_topic_id", using: :btree
    t.index ["user_id"], name: "index_forums_subscriptions_on_user_id", using: :btree
  end

  create_table "forums_threads", force: :cascade do |t|
    t.integer  "topic_id"
    t.integer  "created_by_id",             null: false
    t.string   "title",                     null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "locked"
    t.boolean  "pinned"
    t.boolean  "hidden"
    t.integer  "depth",         default: 0, null: false
    t.index ["created_by_id"], name: "index_forums_threads_on_created_by_id", using: :btree
    t.index ["topic_id"], name: "index_forums_threads_on_topic_id", using: :btree
  end

  create_table "forums_topics", force: :cascade do |t|
    t.integer  "created_by_id",              null: false
    t.string   "name",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "locked"
    t.boolean  "pinned"
    t.boolean  "hidden"
    t.boolean  "isolated"
    t.boolean  "default_hidden"
    t.integer  "ancestry_depth", default: 0, null: false
    t.string   "ancestry"
    t.index ["ancestry"], name: "index_forums_topics_on_ancestry", using: :btree
    t.index ["created_by_id"], name: "index_forums_topics_on_created_by_id", using: :btree
  end

  create_table "games", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_games_on_name", unique: true, using: :btree
  end

  create_table "league_divisions", force: :cascade do |t|
    t.integer  "league_id"
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id"], name: "index_league_divisions_on_league_id", using: :btree
  end

  create_table "league_match_comm_edits", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "comm_id",    null: false
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comm_id"], name: "index_league_match_comm_edits_on_comm_id", using: :btree
    t.index ["user_id"], name: "index_league_match_comm_edits_on_user_id", using: :btree
  end

  create_table "league_match_comms", force: :cascade do |t|
    t.integer  "match_id"
    t.integer  "user_id"
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_league_match_comms_on_match_id", using: :btree
    t.index ["user_id"], name: "index_league_match_comms_on_user_id", using: :btree
  end

  create_table "league_match_pick_bans", force: :cascade do |t|
    t.integer  "match_id",                               null: false
    t.integer  "picked_by_id"
    t.integer  "kind",         limit: 2,                 null: false
    t.integer  "team",         limit: 2,                 null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "map_id"
    t.boolean  "deferrable",             default: false, null: false
    t.index ["map_id"], name: "index_league_match_pick_bans_on_map_id", using: :btree
    t.index ["match_id"], name: "index_league_match_pick_bans_on_match_id", using: :btree
  end

  create_table "league_match_rounds", force: :cascade do |t|
    t.integer  "match_id"
    t.integer  "map_id"
    t.integer  "home_team_score", null: false
    t.integer  "away_team_score", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["map_id"], name: "index_league_match_rounds_on_map_id", using: :btree
    t.index ["match_id"], name: "index_league_match_rounds_on_match_id", using: :btree
  end

  create_table "league_matches", force: :cascade do |t|
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.integer  "status",                    null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "forfeit_by",   default: 0,  null: false
    t.integer  "round_number"
    t.string   "notice",       default: "", null: false
    t.string   "round_name",   default: "", null: false
    t.index ["away_team_id"], name: "index_league_matches_on_away_team_id", using: :btree
    t.index ["home_team_id"], name: "index_league_matches_on_home_team_id", using: :btree
  end

  create_table "league_pooled_maps", force: :cascade do |t|
    t.integer  "league_id"
    t.integer  "map_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id"], name: "index_league_pooled_maps_on_league_id", using: :btree
    t.index ["map_id"], name: "index_league_pooled_maps_on_map_id", using: :btree
  end

  create_table "league_roster_comments", force: :cascade do |t|
    t.integer  "roster_id",  null: false
    t.integer  "user_id"
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["roster_id"], name: "index_league_roster_comments_on_roster_id", using: :btree
    t.index ["user_id"], name: "index_league_roster_comments_on_user_id", using: :btree
  end

  create_table "league_roster_players", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "roster_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["roster_id"], name: "index_league_roster_players_on_roster_id", using: :btree
    t.index ["user_id"], name: "index_league_roster_players_on_user_id", using: :btree
  end

  create_table "league_roster_transfer_requests", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "roster_id"
    t.boolean  "is_joining", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["roster_id"], name: "index_league_roster_transfer_requests_on_roster_id", using: :btree
    t.index ["user_id"], name: "index_league_roster_transfer_requests_on_user_id", using: :btree
  end

  create_table "league_roster_transfers", force: :cascade do |t|
    t.integer  "roster_id",                  null: false
    t.integer  "user_id",                    null: false
    t.boolean  "is_joining",                 null: false
    t.boolean  "approved",   default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["roster_id"], name: "index_league_roster_transfers_on_roster_id", using: :btree
    t.index ["user_id"], name: "index_league_roster_transfers_on_user_id", using: :btree
  end

  create_table "league_rosters", force: :cascade do |t|
    t.integer  "team_id",                                               null: false
    t.integer  "division_id",                                           null: false
    t.boolean  "approved",                              default: false, null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "name",                                                  null: false
    t.text     "description",                                           null: false
    t.boolean  "disbanded",                             default: false, null: false
    t.integer  "ranking"
    t.integer  "seeding"
    t.integer  "won_rounds_count",                      default: 0,     null: false
    t.integer  "drawn_rounds_count",                    default: 0,     null: false
    t.integer  "lost_rounds_count",                     default: 0,     null: false
    t.integer  "forfeit_won_matches_count",             default: 0,     null: false
    t.integer  "forfeit_lost_matches_count",            default: 0,     null: false
    t.integer  "points",                                default: 0,     null: false
    t.integer  "total_scores",                          default: 0,     null: false
    t.json     "schedule_data"
    t.integer  "won_rounds_against_tied_rosters_count", default: 0,     null: false
    t.index ["division_id"], name: "index_league_rosters_on_division_id", using: :btree
    t.index ["points"], name: "index_league_rosters_on_points", using: :btree
    t.index ["team_id"], name: "index_league_rosters_on_team_id", using: :btree
  end

  create_table "league_schedulers_weeklies", force: :cascade do |t|
    t.integer "league_id",                                                             null: false
    t.integer "start_of_week",                                                         null: false
    t.boolean "days",             default: [true, true, true, true, true, true, true], null: false, array: true
    t.integer "minimum_selected", default: 0,                                          null: false
    t.index ["league_id"], name: "index_league_schedulers_weeklies_on_league_id", using: :btree
  end

  create_table "league_tiebreakers", force: :cascade do |t|
    t.integer "league_id"
    t.integer "kind",      null: false
    t.index ["league_id"], name: "index_league_tiebreakers_on_league_id", using: :btree
  end

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
    t.integer  "schedule",                      default: 0,     null: false
    t.boolean  "schedule_locked",               default: false, null: false
    t.string   "query_name_cache",              default: "",    null: false
    t.index "query_name_cache gist_trgm_ops", name: "index_leagues_on_query_name_change", using: :gist
    t.index ["format_id"], name: "index_leagues_on_format_id", using: :btree
  end

  create_table "maps", force: :cascade do |t|
    t.integer  "game_id"
    t.string   "name",        null: false
    t.text     "description", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["game_id"], name: "index_maps_on_game_id", using: :btree
  end

  create_table "team_invites", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_invites_on_team_id", using: :btree
    t.index ["user_id"], name: "index_team_invites_on_user_id", using: :btree
  end

  create_table "team_players", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_players_on_team_id", using: :btree
    t.index ["user_id"], name: "index_team_players_on_user_id", using: :btree
  end

  create_table "team_transfers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.boolean  "is_joining", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_transfers_on_team_id", using: :btree
    t.index ["user_id"], name: "index_team_transfers_on_user_id", using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name",                          null: false
    t.text     "description",                   null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "avatar"
    t.integer  "players_count",    default: 0,  null: false
    t.string   "query_name_cache", default: "", null: false
    t.index "query_name_cache gist_trgm_ops", name: "index_teams_on_query_name_cache", using: :gist
    t.index ["name"], name: "index_teams_on_name", unique: true, using: :btree
  end

  create_table "user_name_changes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "approved_by_id"
    t.integer  "denied_by_id"
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["approved_by_id"], name: "index_user_name_changes_on_approved_by_id", using: :btree
    t.index ["denied_by_id"], name: "index_user_name_changes_on_denied_by_id", using: :btree
    t.index ["user_id"], name: "index_user_name_changes_on_user_id", using: :btree
  end

  create_table "user_notifications", force: :cascade do |t|
    t.integer  "user_id",                    null: false
    t.boolean  "read",       default: false, null: false
    t.string   "message",                    null: false
    t.string   "link",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["user_id"], name: "index_user_notifications_on_user_id", using: :btree
  end

  create_table "user_titles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "league_id"
    t.integer  "roster_id"
    t.string   "name",       null: false
    t.string   "badge"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["league_id"], name: "index_user_titles_on_league_id", using: :btree
    t.index ["roster_id"], name: "index_user_titles_on_roster_id", using: :btree
    t.index ["user_id"], name: "index_user_titles_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                              null: false
    t.bigint   "steam_id",                          null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "description",          default: "", null: false
    t.string   "remember_token"
    t.string   "avatar"
    t.string   "email"
    t.datetime "confirmed_at"
    t.string   "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.string   "query_name_cache",     default: "", null: false
    t.index "query_name_cache gist_trgm_ops", name: "index_users_on_query_name_cache", using: :gist
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["name"], name: "index_users_on_name", unique: true, using: :btree
    t.index ["steam_id"], name: "index_users_on_steam_id", unique: true, using: :btree
  end

  create_table "visits", force: :cascade do |t|
    t.string   "visit_token"
    t.string   "visitor_token"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_visits_on_user_id", using: :btree
    t.index ["visit_token"], name: "index_visits_on_visit_token", unique: true, using: :btree
  end

  add_foreign_key "action_user_edit_forums_thread", "forums_threads"
  add_foreign_key "action_user_edit_forums_thread", "users"
  add_foreign_key "action_user_edit_games", "users"
  add_foreign_key "action_user_edit_league", "leagues"
  add_foreign_key "action_user_edit_league", "users"
  add_foreign_key "action_user_edit_leagues", "users"
  add_foreign_key "action_user_edit_permissions", "users"
  add_foreign_key "action_user_edit_team", "teams"
  add_foreign_key "action_user_edit_team", "users"
  add_foreign_key "action_user_edit_teams", "users"
  add_foreign_key "action_user_edit_users", "users"
  add_foreign_key "action_user_manage_forums", "users"
  add_foreign_key "action_user_manage_forums_thread", "forums_threads"
  add_foreign_key "action_user_manage_forums_thread", "users"
  add_foreign_key "action_user_manage_forums_topic", "forums_topics"
  add_foreign_key "action_user_manage_forums_topic", "users"
  add_foreign_key "action_user_manage_rosters_league", "leagues"
  add_foreign_key "action_user_manage_rosters_league", "users"
  add_foreign_key "action_user_manage_rosters_leagues", "users"
  add_foreign_key "action_user_use_forums_bans", "users"
  add_foreign_key "action_user_use_forums_thread_bans", "forums_threads"
  add_foreign_key "action_user_use_forums_thread_bans", "users"
  add_foreign_key "action_user_use_forums_topic_bans", "forums_topics"
  add_foreign_key "action_user_use_forums_topic_bans", "users"
  add_foreign_key "action_user_use_leagues_bans", "users"
  add_foreign_key "action_user_use_teams_bans", "users"
  add_foreign_key "action_user_use_users_bans", "users"
  add_foreign_key "formats", "games"
  add_foreign_key "forums_post_edits", "forums_posts", column: "post_id"
  add_foreign_key "forums_post_edits", "users", column: "created_by_id"
  add_foreign_key "forums_posts", "forums_threads", column: "thread_id"
  add_foreign_key "forums_posts", "users", column: "created_by_id"
  add_foreign_key "forums_subscriptions", "forums_threads", column: "thread_id"
  add_foreign_key "forums_subscriptions", "forums_topics", column: "topic_id"
  add_foreign_key "forums_subscriptions", "users"
  add_foreign_key "forums_threads", "forums_topics", column: "topic_id"
  add_foreign_key "forums_threads", "users", column: "created_by_id"
  add_foreign_key "forums_topics", "users", column: "created_by_id"
  add_foreign_key "league_divisions", "leagues"
  add_foreign_key "league_match_comm_edits", "league_match_comms", column: "comm_id"
  add_foreign_key "league_match_comm_edits", "users"
  add_foreign_key "league_match_comms", "league_matches", column: "match_id"
  add_foreign_key "league_match_comms", "users"
  add_foreign_key "league_match_pick_bans", "league_matches", column: "match_id"
  add_foreign_key "league_match_pick_bans", "maps"
  add_foreign_key "league_match_pick_bans", "users", column: "picked_by_id"
  add_foreign_key "league_match_rounds", "league_matches", column: "match_id"
  add_foreign_key "league_match_rounds", "maps"
  add_foreign_key "league_matches", "league_rosters", column: "away_team_id"
  add_foreign_key "league_matches", "league_rosters", column: "home_team_id"
  add_foreign_key "league_pooled_maps", "leagues"
  add_foreign_key "league_pooled_maps", "maps"
  add_foreign_key "league_roster_comments", "league_rosters", column: "roster_id"
  add_foreign_key "league_roster_comments", "users"
  add_foreign_key "league_roster_players", "league_rosters", column: "roster_id"
  add_foreign_key "league_roster_players", "users"
  add_foreign_key "league_roster_transfer_requests", "league_rosters", column: "roster_id"
  add_foreign_key "league_roster_transfer_requests", "users"
  add_foreign_key "league_roster_transfers", "league_rosters", column: "roster_id"
  add_foreign_key "league_roster_transfers", "users"
  add_foreign_key "league_rosters", "league_divisions", column: "division_id"
  add_foreign_key "league_rosters", "teams"
  add_foreign_key "league_schedulers_weeklies", "leagues"
  add_foreign_key "league_tiebreakers", "leagues"
  add_foreign_key "leagues", "formats"
  add_foreign_key "maps", "games"
  add_foreign_key "team_invites", "teams"
  add_foreign_key "team_invites", "users"
  add_foreign_key "team_players", "teams"
  add_foreign_key "team_players", "users"
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
