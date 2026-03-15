# frozen_string_literal: true

class CreateDecks < ActiveRecord::Migration[8.1]
  def change
    create_table :decks do |t|
      t.string :name, null: false
      t.boolean :sync_enabled, null: false, default: false
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :decks, :name, unique: true
  end
end
