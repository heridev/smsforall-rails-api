# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_08_003218) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "sms_mobile_hubs", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "device_name", null: false
    t.string "temporal_password"
    t.string "status", default: "pending_activation", null: false
    t.string "device_number", null: false
    t.text "firebase_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.datetime "activated_at"
    t.string "country_international_code", default: ""
  end

  create_table "sms_notifications", force: :cascade do |t|
    t.uuid "unique_id", default: -> { "gen_random_uuid()" }, null: false
    t.text "sms_content"
    t.string "sms_number"
    t.string "status", default: "pending"
    t.integer "processed_by_sms_mobile_hub_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "failed_sent_to_firebase_at"
    t.datetime "failed_delivery_at"
    t.datetime "delivered_at"
    t.datetime "sent_to_firebase_at"
    t.integer "assigned_to_mobile_hub_id"
    t.string "sms_type", default: "transactional"
    t.integer "user_id"
    t.string "kind_of_notification", default: "out", null: false
    t.string "sms_customer_reference_id", default: "", null: false
    t.string "additional_update_info"
    t.datetime "status_updated_by_hub_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.text "jwt_salt"
    t.string "password_hash"
    t.string "password_salt"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "country_international_code", default: ""
    t.boolean "activation_in_progress", default: true
    t.string "mobile_number", default: ""
    t.string "main_api_token_salt"
    t.string "secondary_api_token_salt"
  end

end
