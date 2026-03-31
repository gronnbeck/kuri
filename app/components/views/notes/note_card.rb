# frozen_string_literal: true

class Views::Notes::NoteCard < ApplicationView
  def initialize(note:)
    @note = note
  end

  def view_template
    word = @note.fields.dig("Word", "value").presence
    sentence = @note.fields.dig("Sentence", "value").presence
    definition = @note.fields.dig("Definition", "value")

    a(href: helpers.note_path(@note.anki_id), class: "note-card") do
      div(class: "note-card-word") { word || sentence }
      div(class: "note-card-definition") { plain definition }
    end
  end
end
