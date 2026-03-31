# frozen_string_literal: true

class Views::PhraseCards::New < ApplicationView
  DIFFICULTIES = [ %w[N5 n5], %w[N4 n4], %w[N3 n3], %w[N2 n2], %w[N1 n1] ].freeze

  def initialize(card:)
    @card = card
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Phrase Cards", path: helpers.phrase_cards_path },
        { label: "New" }
      ])
      h1 { "New Phrase Card" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        form(action: helpers.generate_phrase_cards_path, method: "post", data: { turbo: "false" }) do
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

          div(class: "form-group") do
            label(for: "english") { "English phrase" }
            input(
              type: "text",
              name: "english",
              id: "english",
              class: "form-input",
              placeholder: "e.g. Could I have the bill, please?",
              autofocus: true
            )
          end

          div(class: "form-group") do
            label(for: "context") { "Context (optional)" }
            input(
              type: "text",
              name: "context",
              id: "context",
              class: "form-input",
              placeholder: "e.g. at a restaurant, formal situation"
            )
          end

          div(class: "form-group") do
            label(for: "difficulty") { "Difficulty" }
            select(name: "difficulty", id: "difficulty", class: "form-select") do
              DIFFICULTIES.each do |label, val|
                option(value: val) { label }
              end
            end
          end

          button(type: "submit", class: "button") { "Generate" }
        end
      end
    end
  end
end
