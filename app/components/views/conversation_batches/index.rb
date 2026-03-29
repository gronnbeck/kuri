# frozen_string_literal: true

class Views::ConversationBatches::Index < ApplicationView
  def initialize(batches:)
    @batches = batches
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Listen", path: helpers.audio_clips_path },
        { label: "Conversation Batches" }
      ])
      h1 { "Conversation Batches" }
      link_to "New Batch", helpers.new_conversation_batch_path, class: "button"
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        if @batches.empty?
          p(class: "exercise-instructions") { "No batches yet." }
        else
          table(class: "batch-table") do
            thead do
              tr do
                th { "Created" }
                th { "Difficulty" }
                th { "Context" }
                th { "Cards" }
                th { "Status" }
                th { "" }
              end
            end
            tbody do
              @batches.each do |batch|
                tr do
                  td { batch.created_at.strftime("%b %-d, %Y") }
                  td { batch.difficulty.upcase }
                  td { batch.context&.name || "—" }
                  td { "#{batch.completed_count} / #{batch.total}" }
                  td { span(class: "batch-status batch-status--#{batch.status}") { batch.status.capitalize } }
                  td { link_to "View", helpers.conversation_batch_path(batch), class: "button button--small button--secondary" }
                end
              end
            end
          end
        end
      end
    end
  end
end
