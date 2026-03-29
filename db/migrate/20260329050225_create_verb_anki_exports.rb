class CreateVerbAnkiExports < ActiveRecord::Migration[8.1]
  def change
    create_table :verb_anki_exports do |t|
      t.references :verb_transformation_exercise, null: false, foreign_key: true
      t.string  :status,        null: false, default: "pending"
      t.text    :error_message
      t.bigint  :anki_note_id

      t.timestamps
    end
  end
end
