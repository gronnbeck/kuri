# frozen_string_literal: true

class Clip < ApplicationRecord
  belongs_to :actor
  belongs_to :sentence

  has_one_attached :audio

  validates :actor, :sentence, presence: true

  def self.find_or_generate(sentence_text:, actor:)
    sentence = Sentence.find_or_create_by!(text: sentence_text)
    find_by(actor: actor, sentence: sentence) || generate!(actor: actor, sentence: sentence)
  end

  private

  def self.generate!(actor:, sentence:)
    audio_data = ::ElevenLabsTts.call(sentence.text, voice_id: actor.voice_id)
    clip = create!(actor: actor, sentence: sentence)
    clip.audio.attach(
      io:           StringIO.new(audio_data),
      filename:     "clip_#{clip.id}.mp3",
      content_type: "audio/mpeg"
    )
    clip
  end
end
