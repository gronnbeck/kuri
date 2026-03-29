# frozen_string_literal: true

class Views::ConversationBatches::New < ApplicationView
  COUNTS = [ 5, 10, 20, 50, 100 ].freeze

  def initialize(contexts:)
    @contexts = contexts
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Listen",                path: helpers.audio_clips_path },
        { label: "Conversation Batches",  path: helpers.conversation_batches_path },
        { label: "New Batch" }
      ])
      h1 { "New Conversation Batch" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        form(action: helpers.conversation_batches_path, method: "post") do
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

          div(class: "form-row") do
            div(class: "form-group") do
              label(for: "count") { "Cards to generate" }
              select(name: "count", id: "count", class: "form-select") do
                COUNTS.each do |n|
                  option(value: n) { n.to_s }
                end
              end
            end

            div(class: "form-group") do
              label(for: "difficulty") { "Difficulty" }
              select(name: "difficulty", id: "difficulty", class: "form-select") do
                %w[n5 n4 n3 n2 n1].each do |d|
                  option(value: d) { d.upcase }
                end
              end
            end

            div(class: "form-group") do
              label(for: "context_id") { "Context (optional)" }
              select(name: "context_id", id: "context_id", class: "form-select") do
                option(value: "") { "— none —" }
                @contexts.each do |ctx|
                  option(value: ctx.id) { ctx.name }
                end
              end
            end
          end

          div(class: "button-group mt-2") do
            button(type: "submit", class: "button") { "Generate Batch" }
            link_to "Cancel", helpers.conversation_batches_path, class: "button button--secondary"
          end
        end
      end
    end
  end
end
