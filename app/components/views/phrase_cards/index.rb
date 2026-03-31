# frozen_string_literal: true

class Views::PhraseCards::Index < ApplicationView
  def initialize(cards:, show_archived:)
    @cards         = cards
    @show_archived = show_archived
  end

  def view_template
    div(class: "page-header") do
      h1 { "Phrase Cards" }
      div(class: "header-actions") do
        a(href: helpers.phrase_cards_path(archived: @show_archived ? nil : "1"),
          class: "button button--secondary") do
          @show_archived ? "Show active" : "Show archived"
        end
        a(href: helpers.new_phrase_card_path, class: "button") { "New card" }
      end
    end

    if @cards.empty?
      p(class: "muted") { @show_archived ? "No archived cards." : "No cards yet. Generate your first one." }
    else
      div(class: "ce-list") do
        @cards.each do |card|
          div(class: "ce-list-item") do
            a(href: helpers.phrase_card_path(card), class: "ce-list-link") do
              div(class: "ce-list-main") do
                span(class: "ce-list-text") { card.english }
                span(class: "ce-list-text ce-list-text--jp jp") { card.japanese }
              end
              div(class: "ce-list-meta") do
                span(class: "badge") { card.difficulty_level.upcase }
                span(class: "badge badge--audio") { "♪" } if card.audio.attached?
              end
            end
          end
        end
      end
    end
  end
end
