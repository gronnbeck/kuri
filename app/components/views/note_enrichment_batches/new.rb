# frozen_string_literal: true

class Views::NoteEnrichmentBatches::New < ApplicationView
  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Enrich Notes", path: helpers.note_enrichment_batches_path },
        { label: "New" }
      ])
      h1 { "New Note Enrichment" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        p(class: "form-hint") do
          plain "Fetch all notes from an Anki deck, process one field with AI, and save the result to another field."
        end

        form(action: helpers.note_enrichment_batches_path, method: "post", class: "form") do
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

          div(class: "form-row") do
            label(class: "form-label") { "Deck name" }
            input(type: "text", name: "deck_name", class: "form-input", placeholder: "My Japanese Deck", required: true)
          end

          div(class: "form-row") do
            label(class: "form-label") { "Note type" }
            input(type: "text", name: "note_type", class: "form-input", placeholder: "Basic", required: true)
          end

          div(class: "form-row") do
            label(class: "form-label") { "Source field" }
            input(type: "text", name: "source_field", class: "form-input", placeholder: "Expression", required: true)
            span(class: "form-hint-small") { "The field whose value will be processed" }
          end

          div(class: "form-row") do
            label(class: "form-label") { "Destination field" }
            input(type: "text", name: "destination_field", class: "form-input", placeholder: "Reading", required: true)
            span(class: "form-hint-small") { "The field where the result will be written (can be same as source)" }
          end

          div(class: "form-row") do
            label(class: "form-label") { "Transformation" }
            select(name: "transformation", class: "form-input") do
              option(value: "reading")  { "Reading — convert to hiragana" }
              option(value: "translate") { "Translate — Japanese → English" }
              option(value: "furigana") { "Furigana — annotate kanji with HTML <ruby> tags" }
            end
          end

          div(class: "form-actions") do
            button(type: "submit", class: "button") { "Fetch & enrich" }
            link_to "Cancel", helpers.note_enrichment_batches_path, class: "button button--ghost"
          end
        end
      end
    end
  end
end
