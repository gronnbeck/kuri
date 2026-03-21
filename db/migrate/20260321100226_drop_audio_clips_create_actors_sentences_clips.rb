class DropAudioClipsCreateActorsSentencesClips < ActiveRecord::Migration[8.1]
  def change
    drop_table :audio_clips

    create_table :actors do |t|
      t.string :name
      t.string :voice_id, null: false
      t.timestamps
    end

    create_table :sentences do |t|
      t.string :text, null: false
      t.timestamps
    end
    add_index :sentences, :text, unique: true

    create_table :clips do |t|
      t.references :actor, null: false, foreign_key: true
      t.references :sentence, null: false, foreign_key: true
      t.timestamps
    end
    add_index :clips, [ :actor_id, :sentence_id ], unique: true
  end
end
