# frozen_string_literal: true

class Views::Practice::UsefulPhrasesExercise < ApplicationView
  def initialize(mode:, phrase:, phrase_index:, answer:, result:)
    @mode         = mode
    @phrase       = phrase
    @phrase_index = phrase_index
    @answer       = answer
    @result       = result
  end

  def view_template
    div(class: "page-header") do
      h1 { @mode == "consuming" ? "Useful Phrases — Consuming" : "Useful Phrases — Producing" }
      div(class: "header-actions") do
        link_to "Skip →", helpers.useful_phrases_exercise_path(mode: @mode), class: "button button--secondary"
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
          div(
            class: "sp-english",
            data: { controller: "word-hint" }
          ) do
            @phrase[:en].split(" ").each_with_index do |token, i|
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
      unless @result.correct
        div(class: "sp-result-answer") do
          @mode == "consuming" ? @phrase[:en] : @phrase[:jp]
        end
      end
      div(class: "sp-result-countdown", id: "sp-countdown") { "Next in 3..." } if @result.correct
    end
  end

  def render_form
    form(action: helpers.check_useful_phrase_path, method: "post", data: { turbo: "false" }) do
      input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
      input(type: "hidden", name: "mode", value: @mode)
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
    next_url = helpers.useful_phrases_exercise_path(mode: @mode)
    script do
      raw Phlex::SGML::SafeValue.new(<<~JS)
        (function() {
          var remaining = 3;
          var el = document.getElementById('sp-countdown');
          function tick() {
            if (remaining <= 0) { window.location.href = '#{next_url}'; return; }
            if (el) el.textContent = 'Next in ' + remaining + '...';
            remaining--;
            setTimeout(tick, 1000);
          }
          tick();
        })();
      JS
    end
  end
end
