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

ActiveRecord::Schema[8.1].define(version: 2026_03_29_054418) do
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
    t.string "gender"
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "voice_id", null: false
  end

  create_table "anki_conversation_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "deck_name"
    t.json "field_mappings", default: {}
    t.string "note_type"
    t.datetime "updated_at", null: false
    t.string "url", default: "http://localhost:8765"
  end

  create_table "anki_exports", force: :cascade do |t|
    t.bigint "anki_note_id"
    t.integer "conversation_exercise_id", null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_exercise_id"], name: "index_anki_exports_on_conversation_exercise_id"
  end

  create_table "anki_verb_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "deck_name"
    t.json "field_mappings", default: {}
    t.string "note_type"
    t.datetime "updated_at", null: false
    t.string "url", default: "http://localhost:8765"
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

  create_table "contexts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conversation_audios", force: :cascade do |t|
    t.integer "conversation_exercise_id", null: false
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_exercise_id"], name: "index_conversation_audios_on_conversation_exercise_id"
  end

  create_table "conversation_exercises", force: :cascade do |t|
    t.string "anki_status", default: "not_added", null: false
    t.boolean "archived", default: false, null: false
    t.integer "context_id"
    t.datetime "created_at", null: false
    t.string "difficulty_level", default: "n5", null: false
    t.text "notes"
    t.text "request_en"
    t.text "request_jp", null: false
    t.text "request_reading"
    t.text "response_en"
    t.text "response_jp", null: false
    t.text "response_reading"
    t.datetime "updated_at", null: false
    t.index ["context_id"], name: "index_conversation_exercises_on_context_id"
  end

  create_table "conversation_feedbacks", force: :cascade do |t|
    t.text "body"
    t.integer "conversation_exercise_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_exercise_id"], name: "index_conversation_feedbacks_on_conversation_exercise_id"
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

  create_table "verb_anki_exports", force: :cascade do |t|
    t.bigint "anki_note_id"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "verb_transformation_exercise_id", null: false
    t.index ["verb_transformation_exercise_id"], name: "index_verb_anki_exports_on_verb_transformation_exercise_id"
  end

  create_table "verb_audios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.datetime "updated_at", null: false
    t.integer "verb_transformation_exercise_id", null: false
    t.index ["verb_transformation_exercise_id"], name: "index_verb_audios_on_verb_transformation_exercise_id"
  end

  create_table "verb_transformation_exercises", force: :cascade do |t|
    t.string "anki_status", default: "not_added", null: false
    t.text "answer_en"
    t.text "answer_jp", null: false
    t.text "answer_reading"
    t.boolean "archived", default: false, null: false
    t.datetime "created_at", null: false
    t.string "difficulty_level", default: "n5", null: false
    t.text "notes"
    t.string "target_form", null: false
    t.datetime "updated_at", null: false
    t.text "verb_en"
    t.text "verb_jp", null: false
    t.text "verb_reading"
  end

  create_table "verb_transformation_feedbacks", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "verb_transformation_exercise_id", null: false
    t.index ["verb_transformation_exercise_id"], name: "idx_on_verb_transformation_exercise_id_2e9daa9a78"
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
  add_foreign_key "anki_exports", "conversation_exercises"
  add_foreign_key "clips", "actors"
  add_foreign_key "clips", "sentences"
  add_foreign_key "conversation_audios", "conversation_exercises"
  add_foreign_key "conversation_exercises", "contexts"
  add_foreign_key "conversation_feedbacks", "conversation_exercises"
  add_foreign_key "notes", "decks"
  add_foreign_key "verb_anki_exports", "verb_transformation_exercises"
  add_foreign_key "verb_audios", "verb_transformation_exercises"
  add_foreign_key "verb_transformation_feedbacks", "verb_transformation_exercises"
end
