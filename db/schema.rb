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

ActiveRecord::Schema[8.0].define(version: 2026_02_16_141000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_profiles", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_admin_profiles_on_user_id"
  end

  create_table "faq_categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_faq_categories_on_name", unique: true
  end

  create_table "faq_notification_settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_faq_notification_settings_on_user_id", unique: true
  end

  create_table "faq_suggestions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "faq_category_id"
    t.text "domanda", null: false
    t.text "dettagli"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "categoria"
    t.integer "faq_id"
    t.text "risposta"
    t.index ["faq_category_id"], name: "index_faq_suggestions_on_faq_category_id"
    t.index ["faq_id"], name: "index_faq_suggestions_on_faq_id"
    t.index ["user_id"], name: "index_faq_suggestions_on_user_id"
  end

  create_table "faq_translations", force: :cascade do |t|
    t.integer "faq_id", null: false
    t.string "locale", null: false
    t.text "domanda", null: false
    t.text "risposta", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faq_id", "locale"], name: "index_faq_translations_on_faq_id_and_locale", unique: true
    t.index ["faq_id"], name: "index_faq_translations_on_faq_id"
  end

  create_table "faq_votes", force: :cascade do |t|
    t.integer "faq_id", null: false
    t.bigint "user_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faq_id", "user_id"], name: "index_faq_votes_on_faq_id_and_user_id", unique: true
    t.index ["faq_id"], name: "index_faq_votes_on_faq_id"
    t.index ["user_id"], name: "index_faq_votes_on_user_id"
    t.check_constraint "value = ANY (ARRAY[1, '-1'::integer])", name: "check_faq_votes_value"
  end

  create_table "faqs", id: :serial, force: :cascade do |t|
    t.text "domanda", null: false
    t.text "risposta", null: false
    t.text "categoria", null: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.bigint "faq_category_id"
    t.index ["faq_category_id"], name: "index_faqs_on_faq_category_id"
  end

  create_table "favorite_routes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "start_location"
    t.string "end_location"
    t.string "start_name"
    t.string "end_name"
    t.decimal "distance_km", precision: 8, scale: 2
    t.integer "duration_minutes"
    t.string "transport_mode"
    t.integer "search_count", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "start_location", "end_location"], name: "index_favorite_routes_on_user_and_locations", unique: true
    t.index ["user_id"], name: "index_favorite_routes_on_user_id"
  end

  create_table "news", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "category"
    t.string "icon_class"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "percorsi", force: :cascade do |t|
    t.string "partenza"
    t.string "arrivo"
    t.integer "utente"
  end

  create_table "persona", id: :text, force: :cascade do |t|
    t.text "nome", null: false
    t.text "cognome", null: false
    t.date "nascita", null: false
  end

  create_table "profilo", id: :integer, default: nil, force: :cascade do |t|
    t.integer "persona", null: false
    t.integer "ricerhe", default: 0, null: false
    t.json "notifiche"

    t.unique_constraint ["persona"], name: "profilo_persona_key"
  end

  create_table "routes", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "destination", limit: 255
    t.string "destination_name", limit: 255
    t.datetime "searched_at", precision: nil
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["user_id", "searched_at"], name: "index_routes_on_user_id_and_searched_at"
  end

  create_table "sedi", id: :integer, default: nil, force: :cascade do |t|
    t.string "nome", null: false
    t.string "indirizzo", null: false
    t.json "edifici"
    t.json "eventi"
    t.float "lat"
    t.float "long"
    t.index ["nome"], name: "index_sedi_on_nome"
  end

  create_table "student_profiles", force: :cascade do |t|
    t.string "student_id"
    t.string "university"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_student_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
    t.date "registration_date"
    t.integer "role", default: 0, null: false
    t.boolean "terms_accepted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "routes_count", default: 0, null: false
  end

  add_foreign_key "admin_profiles", "users"
  add_foreign_key "faq_notification_settings", "users", on_delete: :cascade
  add_foreign_key "faq_suggestions", "faq_categories", on_delete: :nullify
  add_foreign_key "faq_suggestions", "faqs", on_delete: :nullify
  add_foreign_key "faq_suggestions", "users", on_delete: :cascade
  add_foreign_key "faq_translations", "faqs", on_delete: :cascade
  add_foreign_key "faq_votes", "faqs", on_delete: :cascade
  add_foreign_key "faq_votes", "users", on_delete: :cascade
  add_foreign_key "faqs", "faq_categories"
  add_foreign_key "favorite_routes", "users"
  add_foreign_key "routes", "users", name: "fk_routes_user", on_delete: :cascade
  add_foreign_key "student_profiles", "users"
end
