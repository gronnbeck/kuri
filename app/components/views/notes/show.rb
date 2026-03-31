# frozen_string_literal: true

class Views::Notes::Show < ApplicationView
  def initialize(note:)
    @note = note
  end

  def view_template
    div(class: "page-header") do
      link_to "← Back to notes", helpers.notes_path
      h1 { "Note ##{@note.anki_id}" }
    end

    div(class: "note-detail") do
      @note.fields.each do |field_name, field_data|
        value = field_data["value"].to_s
        div(class: "note-field") do
          div(class: "note-field-header") do
            strong { field_name }
            link_to "Enrich →",
              helpers.try_single_note_enrichments_path(
                source_text:   value,
                anki_note_id:  @note.anki_id,
                field_name:    field_name
              ),
              class: "button button--small button--ghost"
          end
          div(class: "note-field-value") { value }
        end
      end

      if @note.tags.any?
        div(class: "note-tags") do
          em { "Tags: #{@note.tags.join(", ")}" }
        end
      end
    end
  end
end
