# frozen_string_literal: true

class AddDeckToNotes < ActiveRecord::Migration[8.1]
  def change
    remove_column :notes, :deck, :string
    add_reference :notes, :deck, null: false, foreign_key: true
  end
end
