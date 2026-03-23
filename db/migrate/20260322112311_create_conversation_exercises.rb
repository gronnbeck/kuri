class CreateConversationExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :conversation_exercises do |t|
      t.references :context, null: true, foreign_key: true
      t.text :request_jp, null: false
      t.text :response_jp, null: false
      t.text :notes
      t.string :difficulty_level, null: false, default: "n5"
      t.string :anki_status, null: false, default: "not_added"

      t.timestamps
    end
  end
end
