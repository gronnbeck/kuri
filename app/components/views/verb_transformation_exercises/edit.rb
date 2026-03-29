# frozen_string_literal: true

class Views::VerbTransformationExercises::Edit < ApplicationView
  DIFFICULTIES = [ %w[N5 n5], %w[N4 n4], %w[N3 n3], %w[N2 n2], %w[N1 n1] ].freeze

  TARGET_FORM_OPTIONS = VerbTransformationExercise::TARGET_FORM_LABELS.map { |val, label| [ label, val ] }.freeze

  def initialize(exercise:)
    @exercise = exercise
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Listen",         path: helpers.audio_clips_path },
        { label: "Verb Exercises", path: helpers.verb_transformation_exercises_path },
        { label: "Edit" }
      ])
      h1 { "Edit Verb Exercise" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        form(action: helpers.verb_transformation_exercise_path(@exercise), method: "post") do
          input(type: "hidden", name: "_method",            value: "patch")
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

          div(class: "form-row") do
            div(class: "form-group") do
              label(for: "difficulty_level") { "Difficulty" }
              select(name: "verb_transformation_exercise[difficulty_level]", id: "difficulty_level", class: "form-select") do
                DIFFICULTIES.each do |label, val|
                  option(value: val, selected: @exercise.difficulty_level == val) { label }
                end
              end
            end

            div(class: "form-group") do
              label(for: "target_form") { "Target form" }
              select(name: "verb_transformation_exercise[target_form]", id: "target_form", class: "form-select") do
                TARGET_FORM_OPTIONS.each do |label, val|
                  option(value: val, selected: @exercise.target_form == val) { label }
                end
              end
            end
          end

          div(class: "form-row") do
            div(class: "form-group") do
              label(for: "verb_jp") { "Verb (Japanese)" }
              textarea(name: "verb_transformation_exercise[verb_jp]", id: "verb_jp",
                       class: "form-input", rows: "2") { @exercise.verb_jp }
            end
            div(class: "form-group") do
              label(for: "verb_reading") { "Verb reading (hiragana)" }
              textarea(name: "verb_transformation_exercise[verb_reading]", id: "verb_reading",
                       class: "form-input", rows: "2") { @exercise.verb_reading.to_s }
            end
            div(class: "form-group") do
              label(for: "verb_en") { "Verb (English)" }
              textarea(name: "verb_transformation_exercise[verb_en]", id: "verb_en",
                       class: "form-input", rows: "2") { @exercise.verb_en.to_s }
            end
          end

          div(class: "form-row") do
            div(class: "form-group") do
              label(for: "answer_jp") { "Answer (Japanese)" }
              textarea(name: "verb_transformation_exercise[answer_jp]", id: "answer_jp",
                       class: "form-input", rows: "2") { @exercise.answer_jp }
            end
            div(class: "form-group") do
              label(for: "answer_reading") { "Answer reading (hiragana)" }
              textarea(name: "verb_transformation_exercise[answer_reading]", id: "answer_reading",
                       class: "form-input", rows: "2") { @exercise.answer_reading.to_s }
            end
            div(class: "form-group") do
              label(for: "answer_en") { "Answer (English)" }
              textarea(name: "verb_transformation_exercise[answer_en]", id: "answer_en",
                       class: "form-input", rows: "2") { @exercise.answer_en.to_s }
            end
          end

          div(class: "form-group") do
            label(for: "notes") { "Notes (optional)" }
            textarea(name: "verb_transformation_exercise[notes]", id: "notes",
                     class: "form-input", rows: "2",
                     placeholder: "Grammar notes, irregularities, usage tips…") { @exercise.notes.to_s }
          end

          div(class: "button-group") do
            button(type: "submit", class: "button") { "Save" }
            link_to "Cancel", helpers.verb_transformation_exercise_path(@exercise), class: "button button--ghost"
          end
        end
      end
    end
  end
end
