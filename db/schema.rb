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

ActiveRecord::Schema[8.0].define(version: 2024_01_01_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "applets", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "trigger_service_id", null: false
    t.bigint "action_service_id", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_service_id"], name: "index_applets_on_action_service_id"
    t.index ["trigger_service_id"], name: "index_applets_on_trigger_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "icon_url"
    t.string "brand_color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_services_on_slug", unique: true
  end

  add_foreign_key "applets", "services", column: "action_service_id"
  add_foreign_key "applets", "services", column: "trigger_service_id"
end
