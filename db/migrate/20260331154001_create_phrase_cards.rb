class CreatePhraseCards < ActiveRecord::Migration[8.1]
  def change
    create_table :phrase_cards do |t|
      t.text :english
      t.text :context
      t.text :japanese
      t.text :hiragana
      t.text :notes
      t.string :difficulty_level
      t.boolean :archived, default: false, null: false

      t.timestamps
    end
  end
end
