# frozen_string_literal: true

class Views::Practice::GuidedTranslationExercise < ApplicationView
  def initialize(sentence:, answer:, result:)
    @sentence = sentence
    @answer   = answer
    @result   = result
  end

  def view_template
    div(class: "page-header") do
      h1 { "Guided Translation" }
      link_to "Exit", helpers.practice_guided_translation_path, class: "button button--secondary"
    end

    if @sentence.nil?
      p { "No sentences available. Generate some first." }
      return
    end

    div(class: "sp-exercise") do
      div(class: "sp-exercise-prompt") do
        div(class: "sp-pattern-label") { "Translate into Japanese" }
        render Views::Components::WordHintText.new(text: @sentence.english)
      end

      render_result if @result
      render_form   unless @result&.correct
    end

    render_auto_advance_script if @result&.correct
  end

  private

  def render_result
    render Views::Components::ExerciseResult.new(
      result:          @result,
      answer:          @result.correct ? nil : @sentence.japanese,
      countdown_label: "Next sentence in 3..."
    )
  end

  def render_form
    form(action: helpers.check_guided_translation_path, method: "post", data: { turbo: "false" }) do
      input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
      input(type: "hidden", name: "sentence_id", value: @sentence.id)
      textarea(
        class: "practice-input",
        name: "answer",
        placeholder: "Write your Japanese translation here...",
        rows: 3,
        autofocus: true
      ) { @answer.to_s }
      div(class: "sp-form-actions") do
        button(type: "submit", class: "button") { "Check" }
      end
    end
  end

  def render_auto_advance_script
    render Views::Components::ExerciseAutoAdvance.new(
      next_url:         helpers.guided_translation_exercise_path,
      countdown_prefix: "Next sentence in"
    )
  end
end
