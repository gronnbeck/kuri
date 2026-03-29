# frozen_string_literal: true

class Views::ConversationExercises::Show < ApplicationView
  ANKI_CLASSES = { "not_added" => "badge--neutral", "added" => "badge--success", "failed" => "badge--error" }.freeze

  def initialize(exercise:, anki_configured:)
    @exercise        = exercise
    @anki_configured = anki_configured
  end

  def view_template
    div(class: "page-header") do
      div do
        render Views::Components::Breadcrumb.new(items: [
          { label: "Listen",                 path: helpers.audio_clips_path },
          { label: "Conversation Exercises", path: helpers.conversation_exercises_path },
          { label: "Exercise" }
        ])
        h1 { "Conversation Exercise" }
      end
      div(class: "button-group") do
        link_to "Edit", helpers.edit_conversation_exercise_path(@exercise), class: "button button--ghost"
        button_to @exercise.archived? ? "Restore" : "Archive",
          helpers.archive_conversation_exercise_path(@exercise),
          method: :post,
          class: "button button--ghost"
        if @anki_configured
          label = @exercise.added? ? "Re-add to Anki" : "Add to Anki"
          button_to label, helpers.add_to_anki_conversation_exercise_path(@exercise),
            method: :post,
            class: @exercise.added? ? "button button--ghost" : "button"
        else
          span(class: "button button--disabled", title: "Anki is not configured") { "Add to Anki" }
          link_to "Configure Anki →", helpers.settings_listen_conversations_path, class: "button button--ghost button--small"
        end
      end
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        div(class: "ce-meta") do
          render Views::Components::Badge.new(label: @exercise.difficulty_level&.upcase)
          render Views::Components::Badge.new(label: @exercise.context.name, variant: "context") if @exercise.context
          render Views::Components::Badge.new(label: @exercise.anki_status.humanize, variant: ANKI_CLASSES[@exercise.anki_status]&.delete_prefix("badge--"))
        end

        if @exercise.request_reading.blank? || @exercise.response_reading.blank?
          div(class: "ce-missing-readings") do
            span { "Readings missing — Anki export will have empty reading fields." }
            button_to "Generate readings", helpers.generate_readings_conversation_exercise_path(@exercise),
              method: :post, class: "button button--small"
          end
        end

        div(class: "ce-card") do
          div(class: "ce-side") do
            div(class: "ce-side-label") { "Front" }
            div(class: "ce-jp") { @exercise.request_jp }
            div(class: "ce-reading") { @exercise.request_reading } if @exercise.request_reading.present?
            div(class: "ce-en ce-en--hint") { @exercise.response_en } if @exercise.response_en.present?
          end
          div(class: "ce-divider")
          div(class: "ce-side") do
            div(class: "ce-side-label") { "Back" }
            div(class: "ce-jp") { @exercise.response_jp }
            div(class: "ce-reading") { @exercise.response_reading } if @exercise.response_reading.present?
            div(class: "ce-en") { @exercise.request_en } if @exercise.request_en.present?
            div(class: "ce-notes") { @exercise.notes } if @exercise.notes.present?
          end
        end

        render_audio_section
        render_anki_exports if @exercise.anki_exports.any?
        render_feedback_section
      end
    end
  end

  private

  def render_audio_section
    div(class: "ce-audio") do
      div(class: "ce-audio-label") { "Audio" }
      div(class: "ce-audio-row") do
        [ [ "request", @exercise.request_audio ], [ "response", @exercise.response_audio ] ].each do |kind, ca|
          div(class: "ce-audio-item") do
            span(class: "ce-audio-kind") { kind.capitalize }
            if ca&.audio&.attached?
              if ca.pending_audio.attached?
                div(class: "ce-audio-compare") do
                  div(class: "ce-audio-compare-row") do
                    span(class: "ce-audio-compare-label") { "Current" }
                    audio(controls: true, src: helpers.conversation_audio_path(ca), class: "audio-player", preload: "none")
                  end
                  div(class: "ce-audio-compare-row") do
                    span(class: "ce-audio-compare-label") { "New" }
                    audio(controls: true, src: helpers.conversation_audio_path(ca) + "?pending=1", class: "audio-player", preload: "none")
                    button_to "Use new", helpers.confirm_audio_conversation_exercise_path(@exercise, kind: kind),
                      method: :post, class: "button button--small button--success"
                    button_to "Discard", helpers.discard_pending_audio_conversation_exercise_path(@exercise, kind: kind),
                      method: :post, class: "button button--small button--ghost"
                  end
                end
              else
                audio(controls: true, src: helpers.conversation_audio_path(ca), class: "audio-player", preload: "none", style: "flex:1")
                button_to "Regenerate", helpers.regenerate_audio_conversation_exercise_path(@exercise, kind: kind),
                  method: :post, class: "button button--small button--ghost"
              end
            else
              span(class: "ce-audio-missing") { "No audio" }
              link_to "Generate", helpers.generate_audio_conversation_exercise_path(@exercise, kind: kind),
                data: { turbo_method: :post }, class: "button button--small"
            end
          end
        end
      end
    end
  end

  def render_feedback_section
    feedbacks = @exercise.conversation_feedbacks.order(:created_at)
    div(class: "ce-feedback-section") do
      div(class: "ce-feedback-header") do
        h3 { "Feedback" }
        if feedbacks.any?
          button_to "Improve with AI →", helpers.improve_conversation_exercise_path(@exercise),
            method: :post,
            class: "button button--small"
        end
      end

      if feedbacks.any?
        ul(class: "ce-feedback-list") do
          feedbacks.each do |fb|
            li(class: "ce-feedback-item") do
              span(class: "ce-feedback-body") { fb.body }
              button_to "✕", helpers.conversation_exercise_conversation_feedback_path(@exercise, fb),
                method: :delete,
                class: "ce-feedback-remove",
                title: "Remove"
            end
          end
        end
      end

      form(action: helpers.conversation_exercise_conversation_feedbacks_path(@exercise), method: "post", class: "ce-feedback-form") do
        input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
        textarea(
          name: "body",
          class: "form-input",
          rows: "2",
          placeholder: "e.g. The response sounds too formal / The waiter wouldn't ask this / Vocabulary is too hard…"
        )
        div(class: "ce-feedback-form-actions") do
          button(type: "submit", class: "button button--small") { "Save feedback" }
        end
      end
    end
  end

  def render_anki_exports
    div(class: "mt-2") do
      h3 { "Anki Export History" }
      ul(class: "anki-export-list") do
        @exercise.anki_exports.order(created_at: :desc).each do |exp|
          li(class: "anki-export-item") do
            span(class: "badge badge--#{exp.status}") { exp.status }
            span { exp.created_at.strftime("%b %d, %Y %H:%M") }
            span(class: "anki-export-error") { exp.error_message } if exp.failed? && exp.error_message.present?
          end
        end
      end
    end
  end
end
