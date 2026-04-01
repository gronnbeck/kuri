# frozen_string_literal: true

class Views::PhraseCards::Show < ApplicationView
  def initialize(card:, anki_configured: false)
    @card            = card
    @anki_configured = anki_configured
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Phrase Cards", path: helpers.phrase_cards_path },
        { label: @card.english.truncate(40) }
      ])
      div(class: "header-actions") do
        a(href: helpers.edit_phrase_card_path(@card), class: "button button--secondary") { "Edit" }
        button_to @card.archived? ? "Restore" : "Archive",
          helpers.archive_phrase_card_path(@card),
          method: :post, class: "button button--secondary"
      end
    end

    div(class: "exercise-content") do
      # Front
      div(class: "exercise-section") do
        div(class: "ce-meta") do
          span(class: "badge") { @card.difficulty_level.upcase }
        end

        h2(class: "exercise-section-label") { "Front" }

        div(class: "ce-card-face") do
          div(class: "ce-field") do
            div(class: "ce-field-label") { "English" }
            div(class: "ce-field-value") { @card.english }
          end

          if @card.context.present?
            div(class: "ce-field") do
              div(class: "ce-field-label") { "Context" }
              div(class: "ce-field-value ce-field-value--context") { @card.context }
            end
          end
        end
      end

      # Back
      div(class: "exercise-section") do
        h2(class: "exercise-section-label") { "Back" }

        div(class: "ce-card-face") do
          div(class: "ce-field") do
            div(class: "ce-field-label") { "Japanese" }
            div(class: "ce-field-value jp text-xl") { @card.japanese }
          end

          div(class: "ce-field") do
            div(class: "ce-field-label") { "Hiragana" }
            div(class: "ce-field-value jp") { @card.hiragana }
          end

          if @card.audio.attached?
            div(class: "ce-field") do
              div(class: "ce-field-label") { "Audio" }
              audio(controls: true, src: helpers.audio_phrase_card_path(@card), class: "audio-player", preload: "none")
            end
          end

          if @card.notes.present?
            div(class: "ce-field") do
              div(class: "ce-field-label") { "Notes" }
              div(class: "ce-field-value") { @card.notes }
            end
          end
        end
      end

      # Actions
      div(class: "exercise-section") do
        div(class: "header-actions") do
          unless @card.audio.attached?
            button_to "Generate audio", helpers.generate_audio_phrase_card_path(@card),
              method: :post, class: "button"
          end
          if @anki_configured
            button_to(@card.added? ? "Re-add to Anki" : "Add to Anki",
              helpers.add_to_anki_phrase_card_path(@card),
              method: :post, class: "button button--secondary")
          else
            a(href: helpers.settings_listen_phrases_path, class: "button button--secondary") { "Configure Anki" }
          end
          button_to "Delete", helpers.phrase_card_path(@card),
            method: :delete,
            data: { turbo_confirm: "Delete this card?" },
            class: "button button--danger"
        end
      end
    end
  end
end
