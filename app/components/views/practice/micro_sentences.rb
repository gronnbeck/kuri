# frozen_string_literal: true

class Views::Practice::MicroSentences < ApplicationView
  PATTERNS = [
    { pattern: "今日は ___ です。", en: "Today is ___." },
    { pattern: "私は ___ を食べます。", en: "I eat ___." },
    { pattern: "私は ___ を飲みます。", en: "I drink ___." },
    { pattern: "___ に行きます。", en: "I go to ___." },
    { pattern: "夜に ___ をします。", en: "At night I do ___." }
  ].freeze

  EXAMPLES = [
    { jp: "今日は月曜日です。", en: "Today is Monday." },
    { jp: "コーヒーを飲みます。", en: "I drink coffee." },
    { jp: "夜に日本語を勉強します。", en: "At night I study Japanese." }
  ].freeze

  def view_template
    div(class: "page-header") do
      h1 { "Micro Sentences" }
      link_to "← All Exercises", helpers.practice_path, class: "button button--secondary"
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        h2 { "Sentence Patterns" }
        p(class: "exercise-instructions") { "Use these structures to write 5 sentences about your day." }
        ul(class: "pattern-list") do
          PATTERNS.each do |p|
            li(class: "pattern-item") do
              span(class: "jp") { p[:pattern] }
              span(class: "en") { p[:en] }
            end
          end
        end
      end

      div(class: "exercise-section") do
        h2 { "Examples" }
        ul(class: "sentence-list") do
          EXAMPLES.each do |ex|
            li(class: "sentence-item") do
              span(class: "jp") { ex[:jp] }
              span(class: "en") { ex[:en] }
            end
          end
        end
      end

      div(class: "exercise-section exercise-try") do
        h2 { "Your 5 Sentences" }
        p(class: "exercise-instructions") { "Write 5 personal sentences about your day. Reuse vocabulary you already know." }
        (1..5).each do |n|
          div(class: "micro-input-row") do
            span(class: "micro-number") { "#{n}." }
            input(type: "text", class: "micro-input", placeholder: "Japanese sentence...")
          end
        end
      end
    end
  end
end
