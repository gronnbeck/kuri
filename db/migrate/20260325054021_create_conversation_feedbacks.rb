class CreateConversationFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :conversation_feedbacks do |t|
      t.references :conversation_exercise, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
