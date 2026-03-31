# frozen_string_literal: true

module AnkiConnect
  class PhraseExporter
    AUDIO_SOURCES = %w[audio].freeze

    def initialize(setting)
      @setting = setting
      @client  = Client.new(url: setting.url)
    end

    def export(card)
      export_record = card.phrase_anki_exports.create!(status: :pending)

      fields, audio = build_fields_and_audio(card)
      note_id = @client.add_note(
        deck:      @setting.deck_name,
        note_type: @setting.note_type,
        fields:    fields,
        audio:     audio
      )

      export_record.update!(status: :success, anki_note_id: note_id)
      card.update!(anki_status: :added)
      export_record
    rescue => e
      export_record&.update!(status: :failed, error_message: e.message)
      card.update!(anki_status: :failed)
      raise
    end

    private

    def build_fields_and_audio(card)
      mappings = @setting.field_mappings || {}

      text_available = {
        "english"    => card.english.to_s,
        "context"    => card.context.to_s,
        "japanese"   => card.japanese.to_s,
        "hiragana"   => card.hiragana.to_s,
        "notes"      => card.notes.to_s,
        "difficulty" => card.difficulty_level.to_s.upcase
      }

      if mappings.any?
        text_mappings  = mappings.reject { |_, src| AUDIO_SOURCES.include?(src) }
        audio_mappings = mappings.select { |_, src| AUDIO_SOURCES.include?(src) }
        fields = text_mappings.transform_values { |src| text_available[src].to_s }
        audio  = build_audio(card, audio_mappings)
      else
        fields = text_available
        audio  = []
      end

      [ fields, audio ]
    end

    def build_audio(card, audio_mappings)
      audio_mappings.filter_map do |anki_field, _source|
        unless card.audio.attached?
          raise "Audio is not generated yet. Generate it on the card page before exporting."
        end

        {
          url:      "#{app_base_url}/phrase_cards/#{card.id}/audio",
          filename: "kuri_phrase_#{card.id}.mp3",
          fields:   [ anki_field ]
        }
      end
    end

    def app_base_url
      ENV.fetch("APP_URL", "http://localhost:3000")
    end
  end
end
