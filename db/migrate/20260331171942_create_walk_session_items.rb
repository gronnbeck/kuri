class CreateWalkSessionItems < ActiveRecord::Migration[8.1]
  def change
    create_table :walk_session_items do |t|
      t.integer :walk_session_id, null: false
      t.string  :item_type,       null: false
      t.integer :item_id,         null: false
      t.integer :position,        null: false, default: 0

      t.timestamps
    end
  end
end
