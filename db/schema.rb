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

ActiveRecord::Schema[8.0].define(version: 2025_08_25_162340) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "percorsi", id: :integer, default: nil, force: :cascade do |t|
    t.string "partenza", null: false
    t.string "arrivo", null: false
    t.string "mezzo", null: false
  end

  create_table "profilo", id: :integer, default: nil, force: :cascade do |t|
    t.integer "persona", null: false
    t.integer "ricerhe", default: 0, null: false
    t.json "notifiche"

    t.unique_constraint ["persona"], name: "profilo_persona_key"
  end

  create_table "registrazione", id: :integer, default: nil, force: :cascade do |t|
    t.string "email", null: false
    t.string "nome", null: false
    t.string "cognome", null: false
    t.string "password", null: false
    t.date "data", null: false
    t.integer "ruolo", default: 0, null: false
    t.integer "matricola"
    t.string "università"
    t.string "token", default: "1234", null: false
    t.boolean "policy", default: false, null: false

    t.unique_constraint ["email"], name: "Registrazione_email_key"
  end

  create_table "sedes", force: :cascade do |t|
    t.string "nome"
    t.string "indirizzo"
    t.float "lat"
    t.float "long"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sedi", id: :integer, default: nil, force: :cascade do |t|
    t.string "nome", null: false
    t.string "indirizzo", null: false
    t.json "edifici"
    t.json "eventi"
    t.float "lat"
    t.float "long"
  end
end
