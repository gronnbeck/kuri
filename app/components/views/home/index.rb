# frozen_string_literal: true

class Views::Home::Index < ApplicationView
  STAT_LINKS = [
    { key: :conversations, label: "Conversations", path: :conversation_exercises_path },
    { key: :phrases,       label: "Phrases",       path: :phrase_cards_path },
    { key: :verbs,         label: "Verbs",         path: :verb_transformation_exercises_path },
    { key: :notes,         label: "Notes",         path: :notes_path },
    { key: :words,         label: "Words",         path: nil },
    { key: :contexts,      label: "Contexts",      path: nil }
  ].freeze

  def initialize(stats:)
    @stats = stats
  end

  def view_template
    div(class: "welcome") do
      h1 { "Welcome to Kuri" }
      p { "Your personal Japanese learning library." }
    end

    div(class: "stats-grid") do
      STAT_LINKS.each do |stat|
        count = @stats[stat[:key]]
        href  = stat[:path] ? helpers.public_send(stat[:path]) : nil

        tag    = href ? :a : :div
        attrs  = { class: "stat-card" }
        attrs[:href] = href if href

        send(tag, **attrs) do
          span(class: "stat-count") { count.to_s }
          span(class: "stat-label") { stat[:label] }
        end
      end
    end
  end
end
