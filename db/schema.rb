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

ActiveRecord::Schema[8.0].define(version: 2025_08_28_133833) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_profiles", force: :cascade do |t|
    t.string "email"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faqs", id: :serial, force: :cascade do |t|
    t.text "domanda", null: false
    t.text "risposta", null: false
    t.text "categoria", null: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
  end

  create_table "percorsi", force: :cascade do |t|
    t.string "partenza"
    t.string "arrivo"
    t.integer "utente"
    t.decimal "lat"
    t.decimal "long"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "email"
    t.string "student_id"
    t.string "university"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "test_enums", force: :cascade do |t|
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end
end
