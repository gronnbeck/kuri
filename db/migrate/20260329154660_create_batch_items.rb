# frozen_string_literal: true

class CreateBatchItems < ActiveRecord::Migration[8.1]
  def change
    create_table :batch_items do |t|
      t.references :batch,         null: false, foreign_key: true
      t.string     :status,        null: false, default: "pending"
      t.integer    :attempt_count, null: false, default: 0
      t.text       :error_message
      t.string     :exercise_type
      t.integer    :exercise_id
      t.timestamps
    end

    add_index :batch_items, [ :exercise_type, :exercise_id ]
  end
end
