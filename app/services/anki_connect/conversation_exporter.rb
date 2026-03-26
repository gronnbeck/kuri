# frozen_string_literal: true

module AnkiConnect
  class ConversationExporter
    AUDIO_SOURCES = %w[request_audio response_audio].freeze

    def initialize(setting)
      @setting = setting
      @client  = Client.new(url: setting.url)
    end

    def export(exercise)
      export_record = exercise.anki_exports.create!(status: :pending)

      fields, audio = build_fields_and_audio(exercise)
      note_id = @client.add_note(
        deck:      @setting.deck_name,
        note_type: @setting.note_type,
        fields:    fields,
        audio:     audio
      )

      export_record.update!(status: :success, anki_note_id: note_id)
      exercise.update!(anki_status: :added)
      export_record
    rescue => e
      export_record&.update!(status: :failed, error_message: e.message)
      exercise.update!(anki_status: :failed)
      raise
    end

    private

    def build_fields_and_audio(exercise)
      mappings = @setting.field_mappings || {}

      text_available = {
        "request"          => exercise.request_jp,
        "request_reading"  => exercise.request_reading.to_s,
        "response"         => exercise.response_jp,
        "response_reading" => exercise.response_reading.to_s,
        "context"          => exercise.context&.name.to_s,
        "difficulty"       => exercise.difficulty_level.to_s.upcase,
        "notes"            => exercise.notes.to_s
      }

      if mappings.any?
        text_mappings  = mappings.reject { |_, src| AUDIO_SOURCES.include?(src) }
        audio_mappings = mappings.select { |_, src| AUDIO_SOURCES.include?(src) }
        fields = text_mappings.transform_values { |src| text_available[src].to_s }
        audio  = build_audio(exercise, audio_mappings)
      else
        fields = text_available
        audio  = []
      end

      [ fields, audio ]
    end

    def build_audio(exercise, audio_mappings)
      audio_mappings.filter_map do |anki_field, source|
        ca = source == "request_audio" ? exercise.request_audio : exercise.response_audio
        unless ca&.audio&.attached?
          raise "Audio for '#{source}' is not generated yet. Generate it on the exercise page before exporting."
        end

        {
          url:      "#{app_base_url}/conversation_audios/#{ca.id}/audio",
          filename: "kuri_#{source}_#{exercise.id}.mp3",
          fields:   [ anki_field ]
        }
      end
    end

    def app_base_url
      ENV.fetch("APP_URL", "http://localhost:3000")
    end
  end
end
