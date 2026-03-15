# frozen_string_literal: true

class Views::Practice::SentencePatternExercise < ApplicationView
  ADVANCE_DELAY_MS = 3000

  def initialize(pattern:, pattern_index:, english:, answer:, result:)
    @pattern = pattern
    @pattern_index = pattern_index
    @english = english
    @answer = answer
    @result = result
  end

  def view_template
    div(class: "page-header") do
      h1 { "Sentence Patterns" }
      link_to "Exit", helpers.practice_sentence_patterns_path, class: "button button--secondary"
    end

    div(class: "sp-exercise") do
      div(class: "sp-exercise-prompt") do
        div(class: "sp-pattern-label") { "Pattern" }
        div(class: "sp-pattern-formula") { @pattern[:pattern] }
      end

      div(class: "sp-exercise-prompt") do
        div(class: "sp-pattern-label") { "Translate into Japanese" }
        div(
          class: "sp-english",
          data: { controller: "word-hint" }
        ) do
          @english.split(" ").each_with_index do |token, i|
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

      if @result
        render_result
      end

      unless @result&.correct
        render_form
      end
    end

    if @result&.correct
      render_auto_advance_script
    end
  end

  private

  def render_result
    css_class = @result.correct ? "sp-result sp-result--correct" : "sp-result sp-result--incorrect"
    div(class: css_class) do
      div(class: "sp-result-verdict") { @result.correct ? "Correct!" : "Not quite" }
      div(class: "sp-result-feedback") { @result.feedback }
      if @result.correct
        div(class: "sp-result-countdown", id: "sp-countdown") { "Next exercise in 3..." }
      end
    end
  end

  def render_form
    form(action: helpers.check_sentence_pattern_path, method: "post", data: { turbo: "false" }) do
      input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
      input(type: "hidden", name: "pattern_index", value: @pattern_index)
      input(type: "hidden", name: "english", value: @english)
      textarea(
        class: "practice-input",
        name: "answer",
        placeholder: "Write your Japanese sentence here...",
        rows: 3,
        autofocus: true
      ) { @answer.to_s }
      div(class: "sp-form-actions") do
        button(type: "submit", class: "button") { "Check" }
      end
    end
  end

  def render_auto_advance_script
    next_url = helpers.practice_sentence_patterns_exercise_path
    script do
      raw Phlex::SGML::SafeValue.new(<<~JS)
        (function() {
          var remaining = 3;
          var el = document.getElementById('sp-countdown');
          function tick() {
            if (remaining <= 0) { window.location.href = '#{next_url}'; return; }
            if (el) el.textContent = 'Next exercise in ' + remaining + '...';
            remaining--;
            setTimeout(tick, 1000);
          }
          tick();
        })();
      JS
    end
  end
end
