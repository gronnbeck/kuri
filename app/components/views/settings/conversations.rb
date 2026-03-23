# frozen_string_literal: true

class Views::Settings::Conversations < ApplicationView
  EXERCISE_FIELDS = %w[request response context difficulty notes].freeze

  def initialize(setting:)
    @setting = setting
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Settings", path: helpers.settings_path },
        { label: "Listen",   path: helpers.settings_listen_path },
        { label: "Conversations" }
      ])
      h1 { "Anki – Conversations" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        form(action: helpers.settings_listen_conversations_path, method: "post", data: { controller: "anki-settings" }) do
          input(type: "hidden", name: "_method", value: "patch")
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

          h2 { "Connection" }

          div(class: "form-group") do
            label(for: "url") { "AnkiConnect URL" }
            div(class: "form-row-inline") do
              input(
                type: "text",
                name: "anki_conversation_setting[url]",
                id: "url",
                class: "form-input",
                value: @setting.url || "http://localhost:8765",
                placeholder: "http://localhost:8765"
              )
              button(
                type: "button",
                class: "button button--ghost",
                data: { action: "click->anki-settings#testConnection" }
              ) { "Test connection" }
            end
            div(id: "connection-status", class: "form-hint") {}
          end

          h2(class: "mt-2") { "Deck" }

          div(class: "form-row") do
            div(class: "form-group") do
              label(for: "deck_name") { "Deck name" }
              div(class: "form-row-inline") do
                input(
                  type: "text",
                  name: "anki_conversation_setting[deck_name]",
                  id: "deck_name",
                  class: "form-input",
                  value: @setting.deck_name.to_s,
                  placeholder: "Japanese::Conversations"
                )
                button(
                  type: "button",
                  class: "button button--ghost",
                  data: { action: "click->anki-settings#fetchDecks" }
                ) { "Fetch decks" }
              end
              div(id: "decks-list", class: "form-hint") {}
            end

            div(class: "form-group") do
              label(for: "note_type") { "Note type" }
              div(class: "form-row-inline") do
                input(
                  type: "text",
                  name: "anki_conversation_setting[note_type]",
                  id: "note_type",
                  class: "form-input",
                  value: @setting.note_type.to_s,
                  placeholder: "Basic"
                )
                button(
                  type: "button",
                  class: "button button--ghost",
                  data: { action: "click->anki-settings#fetchNoteTypes" }
                ) { "Fetch types" }
              end
              div(id: "note-types-list", class: "form-hint") {}
            end
          end

          h2(class: "mt-2") { "Field Mappings" }
          p(class: "exercise-instructions") {
            "Map each Anki field name to one of: #{EXERCISE_FIELDS.join(", ")}"
          }

          div(id: "field-mappings") do
            mappings = @setting.field_mappings || {}
            if mappings.any?
              mappings.each do |anki_field, source|
                render_mapping_row(anki_field, source)
              end
            else
              render_mapping_row("", "")
            end
          end

          button(
            type: "button",
            class: "button button--ghost button--small mt-1",
            data: { action: "click->anki-settings#addMappingRow" }
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
        name: "anki_conversation_setting[field_mappings][#{anki_field}]",
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
