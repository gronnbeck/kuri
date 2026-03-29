class AddActorToAudios < ActiveRecord::Migration[8.1]
  def change
    add_reference :conversation_audios, :actor, null: true, foreign_key: true
    add_reference :verb_audios,         :actor, null: true, foreign_key: true
  end
end
