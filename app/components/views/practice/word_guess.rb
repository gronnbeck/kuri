# frozen_string_literal: true

class Views::Practice::WordGuess < ApplicationView
  def initialize(note:, guess:)
    @note = note
    @guess = guess
  end

  def view_template
    div(class: "page-header") do
      h1 { "Word Guess" }
      link_to "← All Exercises", helpers.practice_path, class: "button button--secondary"
    end

    if @note.nil?
      p { "No notes available. Add a deck and run a sync first." }
      return
    end

    div(class: "practice") do
      div(class: "practice-card-row") do
        render Views::Notes::NoteCard.new(note: @note)
        if @guess
          div(class: "practice-guess") do
            span(class: "practice-guess-label") { "Guess" }
            span(class: "practice-guess-word") { @guess }
          end
        end
      end

      form(action: helpers.practice_word_guess_path, method: "post", data: { turbo: "false" }) do
        input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
        input(type: "hidden", name: "note_id", value: @note.anki_id)
        textarea(
          class: "practice-input",
          name: "description",
          placeholder: "Describe the word without using it...",
          rows: 4
        ) { }
        button(type: "submit", class: "button") { "Guess" }
      end
    end
  end
end
