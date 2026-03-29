# frozen_string_literal: true

class Views::VerbTransformationExercises::New < ApplicationView
  DIFFICULTIES = [ %w[N5 n5], %w[N4 n4], %w[N3 n3], %w[N2 n2], %w[N1 n1] ].freeze

  TARGET_FORM_OPTIONS = [
    [ "— AI picks for this level —", "" ],
    [ "て-form",           "te_form" ],
    [ "た-form",           "ta_form" ],
    [ "ます-form",         "masu_form" ],
    [ "ない-form",         "nai_form" ],
    [ "Potential",         "potential" ],
    [ "Passive",           "passive" ],
    [ "Causative",         "causative" ],
    [ "Volitional",        "volitional" ],
    [ "Conditional (ば)",  "conditional_ba" ],
    [ "Conditional (たら)", "conditional_tara" ],
    [ "Imperative",        "imperative" ],
    [ "ている-form",       "te_iru" ]
  ].freeze

  def initialize(exercise:)
    @exercise = exercise
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Listen",         path: helpers.audio_clips_path },
        { label: "Verb Exercises", path: helpers.verb_transformation_exercises_path },
        { label: "New" }
      ])
      h1 { "New Verb Exercise" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        form(action: helpers.generate_verb_transformation_exercises_path, method: "post", data: { turbo: "false" }) do
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

          div(class: "form-row") do
            div(class: "form-group") do
              label(for: "difficulty") { "Difficulty" }
              select(name: "difficulty", id: "difficulty", class: "form-select") do
                DIFFICULTIES.each do |label, val|
                  option(value: val) { label }
                end
              end
            end

            div(class: "form-group") do
              label(for: "target_form") { "Target form" }
              select(name: "target_form", id: "target_form", class: "form-select") do
                TARGET_FORM_OPTIONS.each do |label, val|
                  option(value: val) { label }
                end
              end
            end
          end

          div(class: "form-group") do
            label(for: "prompt") { "Additional instructions (optional)" }
            input(
              type: "text",
              name: "prompt",
              id: "prompt",
              class: "form-input",
              placeholder: "e.g. focus on irregular verbs, or use a motion verb"
            )
          end

          button(type: "submit", class: "button") { "Generate" }
        end
      end
    end
  end
end
