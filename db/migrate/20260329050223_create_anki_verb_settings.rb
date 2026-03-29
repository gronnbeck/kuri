class CreateAnkiVerbSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :anki_verb_settings do |t|
      t.string :url,           default: "http://localhost:8765"
      t.string :deck_name
      t.string :note_type
      t.json   :field_mappings, default: {}

      t.timestamps
    end
  end
end
