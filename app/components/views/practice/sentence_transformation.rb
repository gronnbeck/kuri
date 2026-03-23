# frozen_string_literal: true

class Views::Practice::SentenceTransformation < ApplicationView
  SENTENCES = [
    { jp: "私はコーヒーを飲みます。",       en: "I drink coffee." },
    { jp: "私は水を飲みます。",             en: "I drink water." },
    { jp: "田中さんはコーヒーを飲みます。", en: "Tanaka drinks coffee." },
    { jp: "私はコーヒーを飲みません。",     en: "I don't drink coffee." },
    { jp: "私はコーヒーを飲みました。",     en: "I drank coffee." },
    { jp: "私はコーヒーを飲みませんでした。", en: "I didn't drink coffee." },
    { jp: "コーヒーを飲みますか。",         en: "Do you drink coffee?" },
    { jp: "私はお茶を飲みます。",           en: "I drink tea." },
    { jp: "あなたは何を飲みますか。",       en: "What do you drink?" },
    { jp: "私はジュースを飲みたいです。",   en: "I want to drink juice." },
    { jp: "私たちは水を飲みます。",         en: "We drink water." },
    { jp: "子供はミルクを飲みます。",       en: "The child drinks milk." }
  ].freeze

  BASE = { jp: "私はコーヒーを飲みます。", en: "I drink coffee." }.freeze

  def initialize(sentence:, sentence_index:, answer:, result:)
    @sentence       = sentence
    @sentence_index = sentence_index
    @answer         = answer
    @result         = result
  end

  def view_template
    div(class: "page-header") do
      h1 { "Sentence Transformation" }
      link_to "Skip →", helpers.practice_sentence_transformation_path, class: "button button--secondary"
      link_to "← All Exercises", helpers.practice_path, class: "button button--secondary"
    end

    div(class: "sp-exercise") do
      div(class: "sp-exercise-prompt") do
        div(class: "sp-pattern-label") { "Base sentence" }
        div(class: "sp-pattern-formula") { BASE[:jp] }
        div(class: "en", style: "font-size:0.9rem; color:#666; margin-top:0.2rem") { BASE[:en] }
      end

      div(class: "sp-exercise-prompt") do
        div(class: "sp-pattern-label") { "Transform into Japanese" }
        render Views::Components::WordHintText.new(text: @sentence[:en])
      end

      render_result if @result
      render_form   unless @result&.correct
    end

    render_auto_advance_script if @result&.correct
  end

  private

  def render_result
    render Views::Components::ExerciseResult.new(
      result: @result,
      answer: @result.correct ? nil : @sentence[:jp]
    )
  end

  def render_form
    form(action: helpers.practice_sentence_transformation_path, method: "post", data: { turbo: "false" }) do
      input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
      input(type: "hidden", name: "sentence_index", value: @sentence_index)
      textarea(
        class: "practice-input",
        name: "answer",
        placeholder: "Write the Japanese transformation here...",
        rows: 3,
        autofocus: true
      ) { @answer.to_s }
      div(class: "sp-form-actions") do
        button(type: "submit", class: "button") { "Check" }
      end
    end
  end

  def render_auto_advance_script
    render Views::Components::ExerciseAutoAdvance.new(next_url: helpers.practice_sentence_transformation_path)
  end
end
