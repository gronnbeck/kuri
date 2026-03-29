# frozen_string_literal: true

class Views::Settings::Verbs < ApplicationView
  EXERCISE_FIELDS = %w[verb verb_reading verb_en target_form answer answer_reading answer_en verb_audio answer_audio difficulty notes].freeze

  FIELD_DESCRIPTIONS = {
    "verb"           => [ "Japanese", "Verb in dictionary form (front of card)" ],
    "verb_reading"   => [ "Hiragana", "Hiragana-only reading of the verb" ],
    "verb_en"        => [ "Text",     "English meaning of the verb, e.g. to eat" ],
    "target_form"    => [ "Text",     "Conjugation form being drilled, e.g. て-form" ],
    "answer"         => [ "Japanese", "The correctly conjugated form (back of card)" ],
    "answer_reading" => [ "Hiragana", "Hiragana-only reading of the answer" ],
    "answer_en"      => [ "Text",     "English description of the conjugated form" ],
    "verb_audio"     => [ "Audio",    "TTS audio clip of the dictionary form (embedded via AnkiConnect)" ],
    "answer_audio"   => [ "Audio",    "TTS audio clip of the conjugated answer (embedded via AnkiConnect)" ],
    "difficulty"     => [ "Text",     "JLPT level, e.g. N4" ],
    "notes"          => [ "Text",     "Optional grammar or vocabulary notes" ]
  }.freeze

  def initialize(setting:)
    @setting = setting
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Settings", path: helpers.settings_path },
        { label: "Listen",   path: helpers.settings_listen_path },
        { label: "Verbs" }
      ])
      h1 { "Anki – Verb Exercises" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        form(action: helpers.settings_listen_verbs_path, method: "post", data: { controller: "anki-verb-settings" }) do
          input(type: "hidden", name: "_method", value: "patch")
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

          h2 { "Connection" }

          div(class: "form-group") do
            label(for: "url") { "AnkiConnect URL" }
            div(class: "form-row-inline") do
              input(
                type: "text",
                name: "anki_verb_setting[url]",
                id: "url",
                class: "form-input",
                value: @setting.url || "http://localhost:8765",
                placeholder: "http://localhost:8765"
              )
              button(
                type: "button",
                class: "button button--ghost",
                data: { action: "click->anki-verb-settings#testConnection" }
              ) { "Test connection" }
            end
            div(id: "connection-status", class: "form-hint") { }
          end

          h2(class: "mt-2") { "Deck" }

          div(class: "form-row") do
            div(class: "form-group") do
              label(for: "deck_name") { "Deck name" }
              div(class: "form-row-inline") do
                input(
                  type: "text",
                  name: "anki_verb_setting[deck_name]",
                  id: "deck_name",
                  class: "form-input",
                  value: @setting.deck_name.to_s,
                  placeholder: "Japanese::Verbs"
                )
                button(
                  type: "button",
                  class: "button button--ghost",
                  data: { action: "click->anki-verb-settings#fetchDecks" }
                ) { "Fetch decks" }
              end
              div(id: "decks-list", class: "form-hint") { }
            end

            div(class: "form-group") do
              label(for: "note_type") { "Note type" }
              div(class: "form-row-inline") do
                input(
                  type: "text",
                  name: "anki_verb_setting[note_type]",
                  id: "note_type",
                  class: "form-input",
                  value: @setting.note_type.to_s,
                  placeholder: "Basic"
                )
                button(
                  type: "button",
                  class: "button button--ghost",
                  data: { action: "click->anki-verb-settings#fetchNoteTypes" }
                ) { "Fetch types" }
              end
              div(id: "note-types-list", class: "form-hint") { }
            end
          end

          h2(class: "mt-2") { "Available source fields" }
          p(class: "exercise-instructions") {
            "These are the fields Kuri can populate on each Anki note."
          }
          table(class: "field-ref-table") do
            thead do
              tr do
                th { "Field" }
                th { "Type" }
                th { "Description" }
              end
            end
            tbody do
              FIELD_DESCRIPTIONS.each do |name, (type, desc)|
                tr do
                  td { code { name } }
                  td(class: type == "Audio" ? "field-ref-type field-ref-type--audio" : "field-ref-type") { type }
                  td(class: "field-ref-desc") { desc }
                end
              end
            end
          end

          h2(class: "mt-2") { "Field Mappings" }
          div(class: "field-mappings-description") do
            p(class: "exercise-instructions") {
              "Map your Anki note type's field names to the source fields above."
            }
            p(class: "exercise-instructions field-mappings-hint") {
              "Leave empty to use source field names directly — ideal when your Anki fields are named the same as the source fields."
            }
          end

          div(id: "field-mappings") do
            mappings = @setting.field_mappings || {}
            if mappings.any?
              mappings.each do |anki_field, source|
                render_mapping_row(anki_field, source)
              end
            else
              div(class: "field-mappings-empty") do
                span { "No mappings — all source fields will be sent using their default names." }
              end
            end
          end

          button(
            type: "button",
            class: "button button--ghost button--small mt-1",
            data: { action: "click->anki-verb-settings#addMappingRow" }
          ) { "+ Add field" }

          div(class: "button-group mt-2") do
            button(type: "submit", class: "button") { "Save settings" }
          end
        end
      end
    end
  end

  private

  def render_mapping_row(anki_field = "", source = "")
    div(class: "field-mapping-row", data: { controller: "mapping-row" }) do
      input(
        type: "text",
        class: "form-input",
        value: anki_field,
        placeholder: "Anki field name",
        data: { role: "field-name", action: "input->mapping-row#updateName" }
      )
      span { " → " }
      select(
        name: "anki_verb_setting[field_mappings][#{anki_field}]",
        class: "form-select",
        data: { role: "field-source", mapping_row_target: "select" }
      ) do
        option(value: "") { "— select —" }
        EXERCISE_FIELDS.each do |f|
          option(value: f, selected: source == f ? "selected" : nil) { f }
        end
      end
    end
  end
end
