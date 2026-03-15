# frozen_string_literal: true

class Views::Notes::Show < ApplicationView
  def initialize(note:)
    @note = note
  end

  def view_template
    link_to "← Back to notes", helpers.notes_path

    h1 { "Note ##{@note.anki_id}" }
    div(class: "note-detail") do
      @note.fields.each do |field_name, field_data|
        div(class: "note-field") do
          strong { "#{field_name}:" }
          plain " #{field_data["value"]}"
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
