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

ActiveRecord::Schema.define(version: 20160111170234) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "github_pull_requests", force: :cascade do |t|
    t.integer  "github_user_id"
    t.string   "action"
    t.boolean  "merged"
    t.integer  "github_repository_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "event_timestamp"
    t.integer  "original_id"
  end

  add_index "github_pull_requests", ["action"], name: "pull_request_action_idx", using: :btree
  add_index "github_pull_requests", ["github_repository_id"], name: "index_github_pull_requests_on_github_repository_id", using: :btree
  add_index "github_pull_requests", ["github_user_id"], name: "index_github_pull_requests_on_github_user_id", using: :btree
  add_index "github_pull_requests", ["original_id"], name: "index_github_pull_requests_on_original_id", unique: true, using: :btree

  create_table "github_repositories", force: :cascade do |t|
    t.string   "full_name"
    t.integer  "language_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "github_repositories", ["full_name"], name: "index_github_repositories_on_full_name", unique: true, using: :btree
  add_index "github_repositories", ["id"], name: "repo_id_idx", using: :btree
  add_index "github_repositories", ["language_id"], name: "index_github_repositories_on_language_id", using: :btree

  create_table "github_users", force: :cascade do |t|
    t.string   "login"
    t.string   "avatar_url"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "location"
    t.boolean  "reachable",     default: true
    t.string   "linkedin_link"
  end

  add_index "github_users", ["login"], name: "index_github_users_login", unique: true, using: :btree
  add_index "github_users", ["login"], name: "user_login_idx", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "languages", ["id"], name: "lang_id_idx", using: :btree
  add_index "languages", ["name"], name: "index_languages_on_name", unique: true, using: :btree

  add_foreign_key "github_pull_requests", "github_repositories"
  add_foreign_key "github_pull_requests", "github_users"
  add_foreign_key "github_repositories", "languages"

  execute <<-SQL
      CREATE MATERIALIZED VIEW repository_rankings AS
        SELECT github_repositories.id as github_repository_id, count(github_pull_requests.id) as pull_request_count
        FROM github_repositories
        INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
        WHERE github_pull_requests.action = 'opened'
        GROUP BY github_repositories.id
        ORDER BY pull_request_count desc
  SQL

  execute <<-SQL
    CREATE MATERIALIZED VIEW user_rankings AS
      SELECT github_users.id as github_user_id, count(github_pull_requests.id) as pull_request_count
      FROM github_users
      INNER JOIN github_pull_requests on github_pull_requests.github_user_id = github_users.id
      WHERE github_pull_requests.action = 'opened'
      GROUP BY github_users.id
      ORDER BY pull_request_count desc
  SQL
end
