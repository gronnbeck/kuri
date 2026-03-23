# frozen_string_literal: true

module AnkiConnect
  class ConversationExporter
    def initialize(setting)
      @setting = setting
      @client  = Client.new(url: setting.url)
    end

    def export(exercise)
      export_record = exercise.anki_exports.create!(status: :pending)

      fields = build_fields(exercise)
      note_id = @client.add_note(
        deck:      @setting.deck_name,
        note_type: @setting.note_type,
        fields:    fields
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

    def build_fields(exercise)
      mappings = @setting.field_mappings || {}
      available = {
        "request"    => exercise.request_jp,
        "response"   => exercise.response_jp,
        "context"    => exercise.context&.name.to_s,
        "difficulty" => exercise.difficulty_level.to_s.upcase,
        "notes"      => exercise.notes.to_s
      }

      if mappings.any?
        mappings.transform_values { |source_key| available[source_key].to_s }
      else
        available
      end
    end
  end
end
