# frozen_string_literal: true

module AnkiConnect
  class VerbExporter
    AUDIO_SOURCES = %w[verb_audio answer_audio].freeze

    def initialize(setting)
      @setting = setting
      @client  = Client.new(url: setting.url)
    end

    def export(exercise)
      export_record = exercise.verb_anki_exports.create!(status: :pending)

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
        "verb"           => exercise.verb_jp,
        "verb_reading"   => exercise.verb_reading.to_s,
        "verb_en"        => exercise.verb_en.to_s,
        "target_form"    => exercise.target_form_label,
        "answer"         => exercise.answer_jp,
        "answer_reading" => exercise.answer_reading.to_s,
        "answer_en"      => exercise.answer_en.to_s,
        "difficulty"     => exercise.difficulty_level.to_s.upcase,
        "notes"          => exercise.notes.to_s
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
        va = source == "verb_audio" ? exercise.verb_audio : exercise.answer_audio
        unless va&.audio&.attached?
          raise "Audio for '#{source}' is not generated yet. Generate it on the exercise page before exporting."
        end

        {
          url:      "#{app_base_url}/verb_audios/#{va.id}/audio",
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
