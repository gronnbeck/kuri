# frozen_string_literal: true

class Views::PhraseCards::Index < ApplicationView
  DIFFICULTIES = %w[n5 n4 n3 n2 n1].freeze

  def initialize(cards:, pagy:, show_archived:, difficulty:, sort:)
    @cards         = cards
    @pagy          = pagy
    @show_archived = show_archived
    @difficulty    = difficulty
    @sort          = sort
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

    div(class: "filter-bar") do
      # Difficulty filter
      div(class: "filter-bar-group") do
        a(href: filter_path(difficulty: nil), class: filter_class(@difficulty.nil?)) { "All" }
        DIFFICULTIES.each do |d|
          a(href: filter_path(difficulty: d), class: filter_class(@difficulty == d)) { d.upcase }
        end
      end

      # Sort toggle
      div(class: "filter-bar-group") do
        next_sort = @sort == "desc" ? "asc" : "desc"
        a(href: filter_path(sort: next_sort), class: "button button--secondary button--small") do
          @sort == "desc" ? "Newest first ↓" : "Oldest first ↑"
        end
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

      if @pagy.pages > 1
        div(class: "pagination") do
          if @pagy.prev
            a(href: filter_path(page: @pagy.prev), class: "button button--secondary button--small") { "← Previous" }
          end
          span(class: "pagination-info") { "Page #{@pagy.page} of #{@pagy.pages}" }
          if @pagy.next
            a(href: filter_path(page: @pagy.next), class: "button button--secondary button--small") { "Next →" }
          end
        end
      end
    end
  end

  private

  def filter_path(page: nil, **overrides)
    helpers.phrase_cards_path(
      difficulty: @difficulty,
      sort: @sort,
      archived: @show_archived ? "1" : nil,
      **overrides,
      page: page
    )
  end

  def filter_class(active)
    active ? "button button--small button--primary" : "button button--small button--secondary"
  end
end
