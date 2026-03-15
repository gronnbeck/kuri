# frozen_string_literal: true

class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.bigint :anki_id, null: false
      t.string :deck, null: false
      t.json :fields, null: false, default: {}
      t.json :tags, null: false, default: []

      t.timestamps
    end

    add_index :notes, :anki_id, unique: true
    add_index :notes, :deck
  end
end
