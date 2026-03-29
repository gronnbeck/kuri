# frozen_string_literal: true

class Views::VerbTransformationExercises::Index < ApplicationView
  ANKI_CLASSES = { "not_added" => "neutral", "added" => "success", "failed" => "error" }.freeze

  def initialize(exercises:, show_archived: false)
    @exercises     = exercises
    @show_archived = show_archived
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Listen", path: helpers.audio_clips_path },
        { label: "Verb Exercises" }
      ])
      div(class: "page-header-actions") do
        h1 { "Verb Exercises" }
        if @show_archived
          link_to "← Active", helpers.verb_transformation_exercises_path, class: "button button--ghost"
        else
          link_to "Archived", helpers.verb_transformation_exercises_path(archived: 1), class: "button button--ghost"
          link_to "New Exercise", helpers.new_verb_transformation_exercise_path, class: "button"
        end
      end
    end

    div(class: "exercise-content") do
      if @exercises.empty?
        div(class: "exercise-section") do
          p(class: "exercise-instructions") do
            plain "No exercises yet. "
            link_to "Generate one →", helpers.new_verb_transformation_exercise_path
          end
        end
      else
        div(class: "exercise-section") do
          ul(class: "conversation-exercise-list") do
            @exercises.each do |ex|
              li(class: "conversation-exercise-item") do
                a(href: helpers.verb_transformation_exercise_path(ex), class: "conversation-exercise-link", aria_label: "View exercise")
                div(class: "conversation-exercise-text") do
                  div(class: "jp conversation-request") { ex.verb_jp }
                  div(class: "conversation-response") do
                    span(class: "verb-target-form-badge") { ex.target_form_label }
                    span(class: "jp") { " → #{ex.answer_jp}" }
                  end
                end
                div(class: "conversation-exercise-footer") do
                  div(class: "conversation-exercise-meta") do
                    render Views::Components::Badge.new(label: ex.difficulty_level.upcase)
                    render Views::Components::Badge.new(label: ex.anki_status.humanize, variant: ANKI_CLASSES[ex.anki_status])
                  end
                  div(class: "conversation-exercise-actions") do
                    unless @show_archived
                      link_to "Edit", helpers.edit_verb_transformation_exercise_path(ex), class: "button button--small button--ghost"
                    end
                    button_to @show_archived ? "Restore" : "Archive",
                      helpers.archive_verb_transformation_exercise_path(ex),
                      method: :post,
                      class: "button button--small button--ghost"
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
