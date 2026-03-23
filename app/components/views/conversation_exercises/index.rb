# frozen_string_literal: true

class Views::ConversationExercises::Index < ApplicationView
  DIFFICULTY_LABELS = { "n5" => "N5", "n4" => "N4", "n3" => "N3", "n2" => "N2", "n1" => "N1" }.freeze
  ANKI_LABELS = { "not_added" => "Not added", "added" => "Added", "failed" => "Failed" }.freeze
  ANKI_CLASSES = { "not_added" => "badge--neutral", "added" => "badge--success", "failed" => "badge--error" }.freeze

  def initialize(exercises:)
    @exercises = exercises
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Listen", path: helpers.audio_clips_path },
        { label: "Conversation Exercises" }
      ])
      div(class: "page-header-actions") do
        h1 { "Conversation Exercises" }
        link_to "New Exercise", helpers.new_conversation_exercise_path, class: "button"
      end
    end

    div(class: "exercise-content") do
      if @exercises.empty?
        div(class: "exercise-section") do
          p(class: "exercise-instructions") do
            plain "No exercises yet. "
            link_to "Generate one →", helpers.new_conversation_exercise_path
          end
        end
      else
        div(class: "exercise-section") do
          ul(class: "conversation-exercise-list") do
            @exercises.each do |ex|
              li(class: "conversation-exercise-item") do
                div(class: "conversation-exercise-main") do
                  div(class: "conversation-exercise-text") do
                    div(class: "jp conversation-request") { ex.request_jp }
                    div(class: "jp conversation-response") { ex.response_jp }
                  end
                  div(class: "conversation-exercise-meta") do
                    render Views::Components::Badge.new(label: DIFFICULTY_LABELS[ex.difficulty_level] || ex.difficulty_level)
                    render Views::Components::Badge.new(label: ex.context.name, variant: "context") if ex.context
                    render Views::Components::Badge.new(label: ANKI_LABELS[ex.anki_status], variant: ANKI_CLASSES[ex.anki_status]&.delete_prefix("badge--"))
                  end
                end
                div(class: "conversation-exercise-actions") do
                  link_to "View", helpers.conversation_exercise_path(ex), class: "button button--small"
                  link_to "Edit", helpers.edit_conversation_exercise_path(ex), class: "button button--small button--ghost"
                  button_to "Delete", helpers.conversation_exercise_path(ex),
                    method: :delete,
                    data: { confirm: "Delete this exercise?" },
                    class: "button button--small button--danger"
                end
              end
            end
          end
        end
      end
    end
  end
end
