# frozen_string_literal: true

class Views::ConversationExercises::Index < ApplicationView
  DIFFICULTY_LABELS = { "n5" => "N5", "n4" => "N4", "n3" => "N3", "n2" => "N2", "n1" => "N1" }.freeze
  ANKI_LABELS = { "not_added" => "Not added", "added" => "Added", "failed" => "Failed" }.freeze
  ANKI_CLASSES = { "not_added" => "badge--neutral", "added" => "badge--success", "failed" => "badge--error" }.freeze

  DIFFICULTIES = %w[n5 n4 n3 n2 n1].freeze

  def initialize(exercises:, pagy:, show_archived: false, difficulty: nil, sort: "asc")
    @exercises     = exercises
    @pagy          = pagy
    @show_archived = show_archived
    @difficulty    = difficulty
    @sort          = sort
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Listen", path: helpers.audio_clips_path },
        { label: "Conversation Exercises" }
      ])
      div(class: "page-header-actions") do
        h1 { "Conversation Exercises" }
        if @show_archived
          link_to "← Active", helpers.conversation_exercises_path, class: "button button--ghost"
        else
          link_to "Archived", helpers.conversation_exercises_path(archived: 1), class: "button button--ghost"
          link_to "New Exercise", helpers.new_conversation_exercise_path, class: "button"
        end
      end
    end

    div(class: "filter-bar") do
      div(class: "filter-bar-group") do
        a(href: filter_path(difficulty: nil), class: filter_class(@difficulty.nil?)) { "All" }
        DIFFICULTIES.each do |d|
          a(href: filter_path(difficulty: d), class: filter_class(@difficulty == d)) { d.upcase }
        end
      end
      div(class: "filter-bar-group") do
        next_sort = @sort == "desc" ? "asc" : "desc"
        a(href: filter_path(sort: next_sort), class: "button button--secondary button--small") do
          @sort == "desc" ? "Newest first ↓" : "Oldest first ↑"
        end
      end
    end

    div(class: "exercise-content") do
      if @exercises.empty?
        div(class: "exercise-section") do
          p(class: "exercise-instructions") do
            plain "No exercises yet. "
            link_to "Generate one →", helpers.new_conversation_exercise_path
          end
        end
      else
        div(class: "exercise-section") do
          ul(class: "conversation-exercise-list") do
            @exercises.each do |ex|
              li(class: "conversation-exercise-item") do
                a(href: helpers.conversation_exercise_path(ex), class: "conversation-exercise-link", aria_label: "View exercise")
                div(class: "conversation-exercise-text") do
                  div(class: "jp conversation-request") { ex.request_jp }
                  div(class: "jp conversation-response") { ex.response_jp }
                end
                div(class: "conversation-exercise-footer") do
                  div(class: "conversation-exercise-meta") do
                    render Views::Components::Badge.new(label: DIFFICULTY_LABELS[ex.difficulty_level] || ex.difficulty_level)
                    render Views::Components::Badge.new(label: ex.context.name, variant: "context") if ex.context
                    render Views::Components::Badge.new(label: ANKI_LABELS[ex.anki_status], variant: ANKI_CLASSES[ex.anki_status]&.delete_prefix("badge--"))
                  end
                  div(class: "conversation-exercise-actions") do
                    unless @show_archived
                      link_to "Edit", helpers.edit_conversation_exercise_path(ex), class: "button button--small button--ghost"
                    end
                    button_to @show_archived ? "Restore" : "Archive",
                      helpers.archive_conversation_exercise_path(ex),
                      method: :post,
                      class: "button button--small button--ghost"
                  end
                end
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
    helpers.conversation_exercises_path(
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
