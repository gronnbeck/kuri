class CreateWalkSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :walk_sessions do |t|
      t.string :name
      t.integer :inner_pause_ms, default: 2000, null: false
      t.integer :outer_pause_ms, default: 4000, null: false
      t.string  :status, default: "pending", null: false

      t.timestamps
    end
  end
end
