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

ActiveRecord::Schema[7.2].define(version: 2024_06_12_185640) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "payments", force: :cascade do |t|
    t.string "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "payment_link"
    t.string "link_id"
    t.boolean "is_full_payment"
    t.bigint "property_id", null: false
    t.bigint "resident_id", null: false
    t.integer "fee"
    t.index ["property_id"], name: "index_payments_on_property_id"
    t.index ["resident_id"], name: "index_payments_on_resident_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string "name"
    t.string "stripe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "buzz_id"
    t.string "fee_percentage"
    t.integer "property_manager_id"
  end

  create_table "residents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "buzz_id"
    t.bigint "property_id", null: false
    t.index ["property_id"], name: "index_residents_on_property_id"
  end

  add_foreign_key "payments", "properties"
  add_foreign_key "payments", "residents"
  add_foreign_key "properties", "properties", column: "property_manager_id"
  add_foreign_key "residents", "properties"
end
