# frozen_string_literal: true

class Views::PhraseCards::Edit < ApplicationView
  DIFFICULTIES = [ %w[N5 n5], %w[N4 n4], %w[N3 n3], %w[N2 n2], %w[N1 n1] ].freeze

  def initialize(card:)
    @card = card
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Phrase Cards",               path: helpers.phrase_cards_path },
        { label: @card.english.truncate(40),   path: helpers.phrase_card_path(@card) },
        { label: "Edit" }
      ])
      h1 { "Edit Phrase Card" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        form(action: helpers.phrase_card_path(@card), method: "post", data: { turbo: "false" }) do
          input(type: "hidden", name: "_method",            value: "patch")
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

          [
            [ "English",    "phrase_card[english]",    @card.english,    "text" ],
            [ "Context",    "phrase_card[context]",    @card.context,    "text" ],
            [ "Japanese",   "phrase_card[japanese]",   @card.japanese,   "text" ],
            [ "Hiragana",   "phrase_card[hiragana]",   @card.hiragana,   "text" ],
            [ "Notes",      "phrase_card[notes]",      @card.notes,      "text" ]
          ].each do |lbl, name, val, type|
            div(class: "form-group") do
              label(for: name) { lbl }
              input(type: type, name: name, id: name, value: val.to_s, class: "form-input")
            end
          end

          div(class: "form-group") do
            label(for: "phrase_card[difficulty_level]") { "Difficulty" }
            select(name: "phrase_card[difficulty_level]", class: "form-select") do
              DIFFICULTIES.each do |label, val|
                if val == @card.difficulty_level
                  option(value: val, selected: true) { label }
                else
                  option(value: val) { label }
                end
              end
            end
          end

          div(class: "header-actions") do
            button(type: "submit", class: "button") { "Save" }
            a(href: helpers.phrase_card_path(@card), class: "button button--secondary") { "Cancel" }
          end
        end
      end
    end
  end
end
