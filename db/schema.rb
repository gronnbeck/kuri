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

ActiveRecord::Schema[8.1].define(version: 2026_03_15_075608) do
  create_table "decks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_synced_at"
    t.string "name", null: false
    t.boolean "sync_enabled", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_decks_on_name", unique: true
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "anki_id", null: false
    t.datetime "created_at", null: false
    t.integer "deck_id", null: false
    t.json "fields", default: {}, null: false
    t.json "tags", default: [], null: false
    t.datetime "updated_at", null: false
    t.index ["anki_id"], name: "index_notes_on_anki_id", unique: true
    t.index ["deck_id"], name: "index_notes_on_deck_id"
  end

  create_table "words", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "english", null: false
    t.string "furigana"
    t.string "japanese", null: false
    t.datetime "updated_at", null: false
    t.index ["english"], name: "index_words_on_english", unique: true
  end

  add_foreign_key "notes", "decks"
end
