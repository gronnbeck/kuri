class CreateSparringConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :sparring_conversations do |t|
      t.text :history

      t.timestamps
    end
  end
end
