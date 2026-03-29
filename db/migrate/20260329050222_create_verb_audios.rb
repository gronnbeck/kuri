class CreateVerbAudios < ActiveRecord::Migration[8.1]
  def change
    create_table :verb_audios do |t|
      t.references :verb_transformation_exercise, null: false, foreign_key: true
      t.string :kind, null: false

      t.timestamps
    end
  end
end
