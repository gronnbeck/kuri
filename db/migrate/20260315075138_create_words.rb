class CreateWords < ActiveRecord::Migration[8.1]
  def change
    create_table :words do |t|
      t.string :english, null: false
      t.string :japanese, null: false
      t.timestamps
    end

    add_index :words, :english, unique: true
  end
end
