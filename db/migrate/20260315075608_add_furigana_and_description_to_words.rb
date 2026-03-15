class AddFuriganaAndDescriptionToWords < ActiveRecord::Migration[8.1]
  def change
    add_column :words, :furigana, :string
    add_column :words, :description, :string
  end
end
