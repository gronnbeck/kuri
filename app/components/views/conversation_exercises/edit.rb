# frozen_string_literal: true

class Views::ConversationExercises::Edit < ApplicationView
  DIFFICULTIES = [ %w[N5 n5], %w[N4 n4], %w[N3 n3], %w[N2 n2], %w[N1 n1] ].freeze

  def initialize(exercise:, contexts:)
    @exercise = exercise
    @contexts = contexts
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Listen",                 path: helpers.audio_clips_path },
        { label: "Conversation Exercises", path: helpers.conversation_exercises_path },
        { label: "Exercise",               path: helpers.conversation_exercise_path(@exercise) },
        { label: "Edit" }
      ])
      h1 { "Edit Exercise" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        form(action: helpers.conversation_exercise_path(@exercise), method: "post") do
          input(type: "hidden", name: "_method", value: "patch")
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

          div(class: "form-row") do
            div(class: "form-group") do
              label(for: "context_id") { "Context" }
              select(name: "conversation_exercise[context_id]", id: "context_id", class: "form-select") do
                option(value: "") { "— none —" }
                @contexts.each do |ctx|
                  selected = @exercise.context_id == ctx.id
                  option(value: ctx.id, selected: selected ? "selected" : nil) { ctx.name }
                end
              end
            end

            div(class: "form-group") do
              label(for: "difficulty_level") { "Difficulty" }
              select(name: "conversation_exercise[difficulty_level]", id: "difficulty_level", class: "form-select") do
                DIFFICULTIES.each do |label, val|
                  selected = @exercise.difficulty_level == val
                  option(value: val, selected: selected ? "selected" : nil) { label }
                end
              end
            end
          end

          div(class: "form-row") do
            div(class: "form-group") do
              label(for: "request_jp") { "Request (Japanese)" }
              textarea(
                name: "conversation_exercise[request_jp]",
                id: "request_jp",
                class: "form-input",
                rows: "2"
              ) { @exercise.request_jp }
            end

            div(class: "form-group") do
              label(for: "request_reading") { "Request (Reading — hiragana)" }
              textarea(
                name: "conversation_exercise[request_reading]",
                id: "request_reading",
                class: "form-input",
                rows: "2",
                placeholder: "ひらがなのみ"
              ) { @exercise.request_reading.to_s }
            end

            div(class: "form-group") do
              label(for: "request_en") { "Request (English)" }
              textarea(
                name: "conversation_exercise[request_en]",
                id: "request_en",
                class: "form-input",
                rows: "2"
              ) { @exercise.request_en.to_s }
            end
          end

          div(class: "form-row") do
            div(class: "form-group") do
              label(for: "response_jp") { "Response (Japanese)" }
              textarea(
                name: "conversation_exercise[response_jp]",
                id: "response_jp",
                class: "form-input",
                rows: "2"
              ) { @exercise.response_jp }
            end

            div(class: "form-group") do
              label(for: "response_reading") { "Response (Reading — hiragana)" }
              textarea(
                name: "conversation_exercise[response_reading]",
                id: "response_reading",
                class: "form-input",
                rows: "2",
                placeholder: "ひらがなのみ"
              ) { @exercise.response_reading.to_s }
            end

            div(class: "form-group") do
              label(for: "response_en") { "Response (English)" }
              textarea(
                name: "conversation_exercise[response_en]",
                id: "response_en",
                class: "form-input",
                rows: "2"
              ) { @exercise.response_en.to_s }
            end
          end

          div(class: "form-group") do
            label(for: "notes") { "Notes (optional)" }
            textarea(
              name: "conversation_exercise[notes]",
              id: "notes",
              class: "form-input",
              rows: "3",
              placeholder: "Grammar notes, vocabulary hints, cultural context…"
            ) { @exercise.notes.to_s }
          end

          div(class: "button-group") do
            button(type: "submit", class: "button") { "Save" }
            link_to "Cancel", helpers.conversation_exercise_path(@exercise), class: "button button--ghost"
          end
        end
      end
    end
  end
end
