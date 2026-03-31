# frozen_string_literal: true

class Views::NoteEnrichments::TrySingle < ApplicationView
  TRANSFORMATION_LABELS = {
    "reading"   => "Reading — convert to hiragana",
    "translate" => "Translate — Japanese → English",
    "furigana"  => "Furigana — annotate kanji with HTML <ruby> tags",
    "custom"    => "Custom prompt…"
  }.freeze

  def initialize(transformation:, source_text:, result:, error:,
                 custom_prompt: nil, anki_note_id: nil, field_name: nil,
                 target_field_name: nil)
    @transformation    = transformation
    @custom_prompt     = custom_prompt
    @source_text       = source_text
    @anki_note_id      = anki_note_id
    @field_name        = field_name
    @target_field_name = target_field_name
    @result            = result
    @error             = error
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Enrich Notes", path: helpers.note_enrichment_batches_path },
        { label: "Try single" }
      ])
      h1 { "Try Enrichment" }
    end

    div(class: "exercise-content") do
      # Outer wrapper owns fetch-note-fields so all targets are reachable
      # from the same controller instance.
      div(class: "exercise-section",
          data: { controller: "fetch-note-fields" }) do
        # ── Load from Anki ─────────────────────────────────────────────────
        div(class: "enrichment-load-section") do
          div(class: "enrichment-load-header") { "Load from Anki note" }
          div(class: "form--inline") do
            input(type: "number", class: "form-input form-input--small",
                  placeholder: "Note ID",
                  style: "width: 12rem",
                  value: @anki_note_id,
                  data: { fetch_note_fields_target: "noteId" })
            button(type: "button", class: "button button--small button--ghost",
                   data: { action: "click->fetch-note-fields#fetch" }) { "Fetch fields" }
          end

          div(class: "enrichment-load-pickers", style: "display:none",
              data: { fetch_note_fields_target: "pickersWrapper" }) do
            div(class: "enrichment-picker-row") do
              span(class: "enrichment-picker-label") { "Source:" }
              div(class: "enrichment-load-fields",
                  data: { fetch_note_fields_target: "fieldPicker" })
            end
            div(class: "enrichment-picker-row") do
              span(class: "enrichment-picker-label") { "Save to:" }
              div(class: "enrichment-load-fields enrichment-target-picker",
                  data: { fetch_note_fields_target: "targetFieldPicker" })
            end
          end

          span(class: "enrichment-load-error",
               data: { fetch_note_fields_target: "error" })
        end

        # ── Transform form ─────────────────────────────────────────────────
        form(action: helpers.try_single_note_enrichments_path, method: "post",
             class: "form",
             data: { turbo: "false",
                     controller: "toggle-field",
                     toggle_field_show_value: "custom" }) do
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
          input(type: "hidden", name: "anki_note_id", value: @anki_note_id,
                data: { fetch_note_fields_target: "hiddenNoteId" })
          input(type: "hidden", name: "field_name", value: @field_name,
                data: { fetch_note_fields_target: "hiddenFieldName" })
          input(type: "hidden", name: "target_field_name", value: @target_field_name,
                data: { fetch_note_fields_target: "hiddenTargetFieldName" })

          div(class: "form-row") do
            label(class: "form-label") { "Transformation" }
            select(name: "transformation", class: "form-input",
                   data: { toggle_field_target: "select", action: "change->toggle-field#toggle" }) do
              TRANSFORMATION_LABELS.each do |value, label|
                if value == @transformation
                  option(value: value, selected: true) { label }
                else
                  option(value: value) { label }
                end
              end
            end
          end

          div(class: "form-row",
              data: { toggle_field_target: "field" },
              style: @transformation == "custom" ? "" : "display:none") do
            label(class: "form-label") { "Prompt" }
            textarea(name: "custom_prompt", class: "form-input", rows: "3",
                     placeholder: "e.g. Use this word in a short example sentence in Japanese.") { @custom_prompt }
          end

          div(class: "form-row") do
            label(class: "form-label") { "Source text" }
            textarea(name: "source_text", class: "form-input", rows: "4",
                     placeholder: "Paste text here…",
                     data: { fetch_note_fields_target: "source" }) { @source_text }
          end

          div(class: "form-actions") do
            button(type: "submit", class: "button") { "Transform" }
          end
        end

        if @error
          div(class: "enrichment-error-box") do
            strong { "Error: " }
            plain @error
          end
        end

        if @result
          div(class: "enrichment-result-box") do
            div(class: "enrichment-result-header") do
              h3 { "Result" }
            end

            div(class: "enrichment-result-compare") do
              div(class: "enrichment-result-col") do
                div(class: "enrichment-result-label") { "Source" }
                div(class: "enrichment-result-value") { @source_text }
              end
              div(class: "enrichment-result-arrow") { "→" }
              div(class: "enrichment-result-col") do
                div(class: "enrichment-result-label") { "Result" }
                div(class: "enrichment-result-value") { @result }
              end
            end

            div(class: "enrichment-save-section") do
              h4 { "Save to note" }
              p(class: "form-hint") { "Writes the result into the local note record. Use Resync on the Decks page to push to Anki." }

              form(action: helpers.save_to_note_note_enrichments_path, method: "post",
                   class: "form form--inline",
                   data: { turbo: "false" }) do
                input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
                input(type: "hidden", name: "value", value: @result)
                input(type: "hidden", name: "anki_note_id", value: @anki_note_id,
                      data: { fetch_note_fields_target: "hiddenSaveNoteId" })
                input(type: "hidden", name: "field_name", value: @target_field_name,
                      data: { fetch_note_fields_target: "hiddenSaveFieldName" })

                span(class: "enrichment-target-label",
                     data: { fetch_note_fields_target: "targetFieldLabel" }) do
                  @target_field_name ? "→ #{@target_field_name}" : "← pick 'Save to' field above"
                end
                button(type: "submit", class: "button button--small",
                       disabled: @target_field_name.nil?) { "Save to note" }
              end
            end
          end
        end
      end
    end
  end
end
