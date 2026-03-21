class CreateAudioClips < ActiveRecord::Migration[8.1]
  def change
    create_table :audio_clips do |t|
      t.string :text, null: false
      t.string :text_hash, null: false
      t.string :file_path, null: false

      t.timestamps
    end
    add_index :audio_clips, :text_hash, unique: true
  end
end
