class CreateConversationAudios < ActiveRecord::Migration[8.1]
  def change
    create_table :conversation_audios do |t|
      t.references :conversation_exercise, null: false, foreign_key: true
      t.string :kind, null: false

      t.timestamps
    end
  end
end
