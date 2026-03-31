class CreateNoteEnrichments < ActiveRecord::Migration[8.1]
  def change
    create_table :note_enrichments do |t|
      t.references :note_enrichment_batch, null: false, foreign_key: true
      t.integer :anki_note_id, limit: 8
      t.text :source_value
      t.text :enriched_value
      t.string :status
      t.string :error_message

      t.timestamps
    end
  end
end
