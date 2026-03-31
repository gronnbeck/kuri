class CreatePhraseAnkiExports < ActiveRecord::Migration[8.1]
  def change
    create_table :phrase_anki_exports do |t|
      t.integer :phrase_card_id, null: false
      t.bigint  :anki_note_id
      t.string  :status, default: "pending"
      t.text    :error_message

      t.timestamps
    end

    add_index :phrase_anki_exports, :phrase_card_id
  end
end
