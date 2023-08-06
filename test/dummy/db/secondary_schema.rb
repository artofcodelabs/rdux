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

ActiveRecord::Schema[7.0].define(version: 2023_07_13_114436) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "task_id", null: false
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_activities_on_task_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "credit_cards", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "last_four"
    t.integer "expiration_month"
    t.integer "expiration_year"
    t.string "token"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_credit_cards_on_user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.string "ext_charge_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_plans_on_user_id"
  end

  create_table "rdux_actions", force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "up_payload", null: false
    t.jsonb "down_payload"
    t.datetime "down_at"
    t.boolean "up_payload_sanitized", default: false, null: false
    t.jsonb "up_result"
    t.jsonb "meta"
    t.string "stream_hash"
    t.bigint "rdux_action_id"
    t.bigint "rdux_failed_action_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rdux_action_id"], name: "index_rdux_actions_on_rdux_action_id"
    t.index ["rdux_failed_action_id"], name: "index_rdux_actions_on_rdux_failed_action_id"
  end

  create_table "rdux_failed_actions", force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "up_payload", null: false
    t.boolean "up_payload_sanitized", default: false, null: false
    t.jsonb "up_result"
    t.jsonb "meta"
    t.string "stream_hash"
    t.bigint "rdux_failed_action_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rdux_failed_action_id"], name: "index_rdux_failed_actions_on_rdux_failed_action_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "activities", "tasks"
  add_foreign_key "activities", "users"
  add_foreign_key "credit_cards", "users"
  add_foreign_key "plans", "users"
  add_foreign_key "rdux_actions", "rdux_actions"
  add_foreign_key "rdux_actions", "rdux_failed_actions"
  add_foreign_key "rdux_failed_actions", "rdux_failed_actions"
  add_foreign_key "tasks", "users"
end
