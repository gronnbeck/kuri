# frozen_string_literal: true

class Views::Practice::UsefulPhrases < ApplicationView
  def view_template
    div(class: "page-header") do
      h1 { "Useful Phrases" }
      link_to "← All Exercises", helpers.practice_path, class: "button button--secondary"
    end

    p(class: "exercise-instructions") do
      "Practice phrases from real Japanese contexts. Choose your mode."
    end

    div(class: "exercise-grid") do
      a(href: helpers.useful_phrases_exercise_path(mode: "consuming"), class: "exercise-card") do
        div(class: "exercise-card-header") do
          h2(class: "exercise-card-title") { "Consuming" }
          span(class: "difficulty-badge difficulty-badge--easy") { "Easy" }
        end
        p(class: "exercise-card-desc") { "You're shown a Japanese phrase — translate it into English." }
      end

      a(href: helpers.useful_phrases_exercise_path(mode: "producing"), class: "exercise-card") do
        div(class: "exercise-card-header") do
          h2(class: "exercise-card-title") { "Producing" }
          span(class: "difficulty-badge difficulty-badge--medium") { "Medium" }
        end
        p(class: "exercise-card-desc") { "You're shown an English phrase — write it in Japanese." }
      end
    end
  end
end
