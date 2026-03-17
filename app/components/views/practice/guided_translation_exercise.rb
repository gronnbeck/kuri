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
        div(
          class: "sp-english",
          data: { controller: "word-hint" }
        ) do
          @sentence.english.split(" ").each_with_index do |token, i|
            plain " " if i > 0
            bare_word = token.gsub(/\A[^a-zA-Z0-9]+|[^a-zA-Z0-9]+\z/, "")
            span(
              class: "sp-word",
              data: {
                word_hint_target: "word",
                action: "click->word-hint#lookup",
                word: bare_word
              }
            ) { token }
          end
        end
      end

      render_result if @result
      render_form   unless @result&.correct
    end

    render_auto_advance_script if @result&.correct
  end

  private

  def render_result
    css = @result.correct ? "sp-result sp-result--correct" : "sp-result sp-result--incorrect"
    div(class: css) do
      div(class: "sp-result-verdict")  { @result.correct ? "Correct!" : "Not quite" }
      div(class: "sp-result-feedback") { @result.feedback }
      div(class: "sp-result-answer")   { @sentence.japanese } unless @result.correct
      div(class: "sp-result-countdown", id: "sp-countdown") { "Next sentence in 3..." } if @result.correct
    end
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
    next_url = helpers.guided_translation_exercise_path
    script do
      raw Phlex::SGML::SafeValue.new(<<~JS)
        (function() {
          var remaining = 3;
          var el = document.getElementById('sp-countdown');
          function tick() {
            if (remaining <= 0) { window.location.href = '#{next_url}'; return; }
            if (el) el.textContent = 'Next sentence in ' + remaining + '...';
            remaining--;
            setTimeout(tick, 1000);
          }
          tick();
        })();
      JS
    end
  end
end
