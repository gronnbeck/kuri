# frozen_string_literal: true

class Views::Practice::UsefulPhrasesExercise < ApplicationView
  def initialize(mode:, context:, phrase:, phrase_index:, answer:, result:)
    @mode         = mode
    @context      = context
    @phrase       = phrase
    @phrase_index = phrase_index
    @answer       = answer
    @result       = result
  end

  def view_template
    div(class: "page-header") do
      h1 { @mode == "consuming" ? "Useful Phrases — Consuming" : "Useful Phrases — Producing" }
      div(class: "header-actions") do
        link_to "Skip →", helpers.useful_phrases_exercise_path(mode: @mode, context: @context), class: "button button--secondary"
        link_to "← All Exercises", helpers.practice_useful_phrases_path, class: "button button--secondary"
      end
    end

    div(class: "sp-exercise") do
      div(class: "sp-exercise-prompt") do
        span(class: "sp-pattern-label") { @phrase[:context] }
      end

      div(class: "sp-exercise-prompt") do
        div(class: "sp-pattern-label") do
          @mode == "consuming" ? "Translate into English" : "Write in Japanese"
        end

        if @mode == "consuming"
          div(class: "sp-pattern-formula") { @phrase[:jp] }
        else
          render Views::Components::WordHintText.new(text: @phrase[:en])
        end
      end

      render_result if @result
      render_form   unless @result&.correct
    end

    render_auto_advance_script if @result&.correct
  end

  private

  def render_result
    answer = @result.correct ? nil : (@mode == "consuming" ? @phrase[:en] : @phrase[:jp])
    render Views::Components::ExerciseResult.new(result: @result, answer: answer)
  end

  def render_form
    form(action: helpers.check_useful_phrase_path, method: "post", data: { turbo: "false" }) do
      input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
      input(type: "hidden", name: "mode", value: @mode)
      input(type: "hidden", name: "context", value: @context)
      input(type: "hidden", name: "phrase_index", value: @phrase_index)
      textarea(
        class: "practice-input",
        name: "answer",
        placeholder: @mode == "consuming" ? "Write the English translation here..." : "Write the Japanese phrase here...",
        rows: 2,
        autofocus: true
      ) { @answer.to_s }
      div(class: "sp-form-actions") do
        button(type: "submit", class: "button") { "Check" }
      end
    end
  end

  def render_auto_advance_script
    render Views::Components::ExerciseAutoAdvance.new(
      next_url: helpers.useful_phrases_exercise_path(mode: @mode, context: @context)
    )
  end
end
