class AddArchivedToConversationExercises < ActiveRecord::Migration[8.1]
  def change
    add_column :conversation_exercises, :archived, :boolean, null: false, default: false
  end
end
