class AddAnkiStatusToPhraseCards < ActiveRecord::Migration[8.1]
  def change
    add_column :phrase_cards, :anki_status, :string, default: "not_added"
  end
end
