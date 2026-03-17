class CreateTranslationSentences < ActiveRecord::Migration[8.1]
  def change
    create_table :translation_sentences do |t|
      t.string :english, null: false
      t.string :japanese, null: false

      t.timestamps
    end
  end
end
