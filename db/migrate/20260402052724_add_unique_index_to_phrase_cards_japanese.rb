class AddUniqueIndexToPhraseCardsJapanese < ActiveRecord::Migration[8.1]
  def change
    # Remove duplicate rows before adding the constraint, keeping the oldest record
    execute <<~SQL
      DELETE FROM phrase_cards
      WHERE id NOT IN (
        SELECT MIN(id) FROM phrase_cards GROUP BY japanese
      )
    SQL
    add_index :phrase_cards, :japanese, unique: true
  end
end
