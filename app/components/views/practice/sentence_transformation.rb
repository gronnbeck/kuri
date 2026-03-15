# frozen_string_literal: true

class Views::Practice::SentenceTransformation < ApplicationView
  SENTENCES = [
    { jp: "私はコーヒーを飲みます。", en: "I drink coffee." },
    { jp: "私は水を飲みます。", en: "I drink water." },
    { jp: "田中さんはコーヒーを飲みます。", en: "Tanaka drinks coffee." },
    { jp: "私はコーヒーを飲みません。", en: "I don't drink coffee." },
    { jp: "私はコーヒーを飲みました。", en: "I drank coffee." },
    { jp: "私はコーヒーを飲みませんでした。", en: "I didn't drink coffee." },
    { jp: "コーヒーを飲みますか。", en: "Do you drink coffee?" },
    { jp: "私はお茶を飲みます。", en: "I drink tea." },
    { jp: "あなたは何を飲みますか。", en: "What do you drink?" },
    { jp: "私はジュースを飲みたいです。", en: "I want to drink juice." },
    { jp: "私たちは水を飲みます。", en: "We drink water." },
    { jp: "子供はミルクを飲みます。", en: "The child drinks milk." }
  ].freeze

  def view_template
    div(class: "page-header") do
      h1 { "Sentence Transformation" }
      link_to "← All Exercises", helpers.practice_path, class: "button button--secondary"
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        h2 { "Base Pattern" }
        div(class: "exercise-base-sentence") do
          p(class: "jp") { "私はコーヒーを飲みます。" }
          p(class: "en") { "I drink coffee." }
        end
      end

      div(class: "exercise-section") do
        h2 { "Transformations" }
        p(class: "exercise-instructions") do
          "For each sentence: say it out loud, rewrite it yourself, then try replacing words with your own vocabulary."
        end
        ol(class: "sentence-list") do
          SENTENCES.each do |s|
            li(class: "sentence-item") do
              span(class: "jp") { s[:jp] }
              span(class: "en") { s[:en] }
            end
          end
        end
      end

      div(class: "exercise-section exercise-try") do
        h2 { "Try It Yourself" }
        p(class: "exercise-instructions") { "Pick a new base word and create your own 5 transformations below." }
        textarea(class: "practice-input", rows: 8, placeholder: "Write your own transformations here...") {}
      end
    end
  end
end
