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

ActiveRecord::Schema[8.1].define(version: 2026_03_21_100226) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "actors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "voice_id", null: false
  end

  create_table "clips", force: :cascade do |t|
    t.integer "actor_id", null: false
    t.datetime "created_at", null: false
    t.integer "sentence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "sentence_id"], name: "index_clips_on_actor_id_and_sentence_id", unique: true
    t.index ["actor_id"], name: "index_clips_on_actor_id"
    t.index ["sentence_id"], name: "index_clips_on_sentence_id"
  end

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

  create_table "sentences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "text", null: false
    t.datetime "updated_at", null: false
    t.index ["text"], name: "index_sentences_on_text", unique: true
  end

  create_table "translation_sentences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "english", null: false
    t.string "japanese", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "clips", "actors"
  add_foreign_key "clips", "sentences"
  add_foreign_key "notes", "decks"
end
