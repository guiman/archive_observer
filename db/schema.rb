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

ActiveRecord::Schema.define(version: 20151022183731) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "github_pull_requests", force: :cascade do |t|
    t.time     "event_timestamp"
    t.integer  "github_user_id"
    t.string   "action"
    t.boolean  "merged"
    t.integer  "github_repository_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "github_pull_requests", ["github_repository_id"], name: "index_github_pull_requests_on_github_repository_id", using: :btree
  add_index "github_pull_requests", ["github_user_id"], name: "index_github_pull_requests_on_github_user_id", using: :btree

  create_table "github_repositories", force: :cascade do |t|
    t.string   "full_name"
    t.integer  "language_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "github_repositories", ["language_id"], name: "index_github_repositories_on_language_id", using: :btree

  create_table "github_users", force: :cascade do |t|
    t.string   "login"
    t.string   "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "languages", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "github_pull_requests", "github_repositories"
  add_foreign_key "github_pull_requests", "github_users"
  add_foreign_key "github_repositories", "languages"
end