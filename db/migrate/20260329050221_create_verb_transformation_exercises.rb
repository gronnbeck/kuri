class CreateVerbTransformationExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :verb_transformation_exercises do |t|
      t.text    :verb_jp,          null: false
      t.text    :verb_en
      t.text    :verb_reading
      t.string  :target_form,      null: false
      t.text    :answer_jp,        null: false
      t.text    :answer_en
      t.text    :answer_reading
      t.text    :notes
      t.string  :difficulty_level, null: false, default: "n5"
      t.string  :anki_status,      null: false, default: "not_added"
      t.boolean :archived,         null: false, default: false

      t.timestamps
    end
  end
end
