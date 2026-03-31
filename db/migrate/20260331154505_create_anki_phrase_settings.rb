class CreateAnkiPhraseSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :anki_phrase_settings do |t|
      t.string :url
      t.string :deck_name
      t.string :note_type
      t.json :field_mappings, default: {}

      t.timestamps
    end
  end
end
