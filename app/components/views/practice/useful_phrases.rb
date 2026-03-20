# frozen_string_literal: true

class Views::Practice::UsefulPhrases < ApplicationView
  def view_template
    div(class: "page-header") do
      h1 { "Useful Phrases" }
      link_to "← All Exercises", helpers.practice_path, class: "button button--secondary"
    end

    p(class: "exercise-instructions") do
      "Choose a scenario and a mode to start practicing."
    end

    div(class: "up-scenario-list") do
      Views::Practice::DailyConversations::THEMES.each do |key, theme|
        render_scenario_row(theme[:emoji], theme[:name], key)
      end
      render_scenario_row("🎲", "Mix", "mix")
    end
  end

  private

  def render_scenario_row(emoji, name, context_key)
    div(class: "up-scenario-row") do
      div(class: "up-scenario-name") { "#{emoji} #{name}" }
      div(class: "up-scenario-actions") do
        link_to(
          "Consuming",
          helpers.useful_phrases_exercise_path(mode: "consuming", context: context_key),
          class: "button button--secondary"
        )
        link_to(
          "Producing",
          helpers.useful_phrases_exercise_path(mode: "producing", context: context_key),
          class: "button"
        )
      end
    end
  end
end
