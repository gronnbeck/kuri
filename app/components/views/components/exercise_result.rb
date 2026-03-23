# frozen_string_literal: true

# Renders the result block for a practice exercise (correct/incorrect feedback).
#
# Usage:
#   render Views::Components::ExerciseResult.new(
#     result:          @result,
#     answer:          @sentence[:jp],    # shown when incorrect (optional)
#     countdown_label: "Next in 3..."     # shown in the countdown span when correct
#   )
class Views::Components::ExerciseResult < ApplicationView
  def initialize(result:, answer: nil, countdown_label: "Next in 3...")
    @result          = result
    @answer          = answer
    @countdown_label = countdown_label
  end

  def view_template
    css = @result.correct ? "sp-result sp-result--correct" : "sp-result sp-result--incorrect"
    div(class: css) do
      div(class: "sp-result-verdict")  { @result.correct ? "Correct!" : "Not quite" }
      div(class: "sp-result-feedback") { @result.feedback }
      div(class: "sp-result-answer")   { @answer } if !@result.correct && @answer
      div(class: "sp-result-countdown", id: "sp-countdown") { @countdown_label } if @result.correct
    end
  end
end
