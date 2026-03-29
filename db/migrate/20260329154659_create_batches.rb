# frozen_string_literal: true

class CreateBatches < ActiveRecord::Migration[8.1]
  def change
    create_table :batches do |t|
      t.string  :kind,            null: false
      t.string  :status,          null: false, default: "pending"
      t.integer :total,           null: false
      t.integer :completed_count, null: false, default: 0
      t.integer :failed_count,    null: false, default: 0
      t.string  :difficulty,      null: false
      t.references :context, null: true, foreign_key: true
      t.string :target_form
      t.timestamps
    end
  end
end
