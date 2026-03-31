class CreateNoteEnrichmentBatches < ActiveRecord::Migration[8.1]
  def change
    create_table :note_enrichment_batches do |t|
      t.string :deck_name
      t.string :note_type
      t.string :source_field
      t.string :destination_field
      t.string :transformation
      t.string :status
      t.integer :total, default: 0
      t.integer :enriched_count, default: 0
      t.integer :approved_count, default: 0
      t.integer :pushed_count, default: 0
      t.integer :failed_count, default: 0

      t.timestamps
    end
  end
end
