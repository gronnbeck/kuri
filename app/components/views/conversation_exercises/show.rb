# frozen_string_literal: true

class Views::ConversationExercises::Show < ApplicationView
  ANKI_CLASSES = { "not_added" => "badge--neutral", "added" => "badge--success", "failed" => "badge--error" }.freeze

  def initialize(exercise:)
    @exercise = exercise
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
        unless @exercise.added?
          button_to "Add to Anki", helpers.add_to_anki_conversation_exercise_path(@exercise),
            method: :post,
            class: "button"
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

        div(class: "ce-card") do
          div(class: "ce-side") do
            div(class: "ce-side-label") { "Front" }
            div(class: "ce-jp") { @exercise.request_jp }
            div(class: "ce-en ce-en--hint") { @exercise.response_en } if @exercise.response_en.present?
          end
          div(class: "ce-divider")
          div(class: "ce-side") do
            div(class: "ce-side-label") { "Back" }
            div(class: "ce-jp") { @exercise.response_jp }
            div(class: "ce-en") { @exercise.request_en } if @exercise.request_en.present?
            div(class: "ce-notes") { @exercise.notes } if @exercise.notes.present?
          end
        end

        render_audio_section
        render_anki_exports if @exercise.anki_exports.any?
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
              audio(controls: true, src: helpers.conversation_audio_path(ca), class: "audio-player", preload: "none", style: "flex:1")
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
