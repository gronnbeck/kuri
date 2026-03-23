class AddEnglishToConversationExercises < ActiveRecord::Migration[8.1]
  def change
    add_column :conversation_exercises, :request_en, :text
    add_column :conversation_exercises, :response_en, :text
  end
end
