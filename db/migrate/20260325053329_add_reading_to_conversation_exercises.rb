class AddReadingToConversationExercises < ActiveRecord::Migration[8.1]
  def change
    add_column :conversation_exercises, :request_reading, :text
    add_column :conversation_exercises, :response_reading, :text
  end
end
