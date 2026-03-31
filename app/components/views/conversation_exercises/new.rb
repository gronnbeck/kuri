# frozen_string_literal: true

class Views::ConversationExercises::New < ApplicationView
  DIFFICULTIES = [ %w[N5 n5], %w[N4 n4], %w[N3 n3], %w[N2 n2], %w[N1 n1] ].freeze

  def initialize(contexts:, exercise:)
    @contexts  = contexts
    @exercise  = exercise
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Listen",                  path: helpers.audio_clips_path },
        { label: "Conversation Exercises",  path: helpers.conversation_exercises_path },
        { label: "New" }
      ])
      h1 { "New Conversation Exercise" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        form(action: helpers.generate_conversation_exercises_path, method: "post", data: { turbo: "false" }) do
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

          div(class: "form-row") do
            div(class: "form-group") do
              label(for: "context_id") { "Context" }
              select(name: "context_id", id: "context_id", class: "form-select") do
                option(value: "") { "— none —" }
                @contexts.each do |ctx|
                  option(value: ctx.id) { ctx.name }
                end
              end
            end

            div(class: "form-group") do
              label(for: "difficulty") { "Difficulty" }
              select(name: "difficulty", id: "difficulty", class: "form-select") do
                DIFFICULTIES.each do |label, val|
                  option(value: val) { label }
                end
              end
            end
          end

          div(class: "form-group") do
            label(for: "prompt") { "Instructions (optional)" }
            input(
              type: "text",
              name: "prompt",
              id: "prompt",
              class: "form-input",
              placeholder: "e.g. ordering ramen at a restaurant"
            )
          end

          button(type: "submit", class: "button") { "Generate" }
        end
      end
    end
  end
end
