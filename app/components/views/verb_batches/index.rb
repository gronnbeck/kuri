# frozen_string_literal: true

class Views::VerbBatches::Index < ApplicationView
  def initialize(batches:)
    @batches = batches
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Listen", path: helpers.audio_clips_path },
        { label: "Verb Batches" }
      ])
      h1 { "Verb Batches" }
      link_to "New Batch", helpers.new_verb_batch_path, class: "button"
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
                th { "Target Form" }
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
                  td { batch.target_form.present? ? VerbTransformationExercise::TARGET_FORM_LABELS[batch.target_form] : "Random" }
                  td { "#{batch.completed_count} / #{batch.total}" }
                  td { span(class: "batch-status batch-status--#{batch.status}") { batch.status.capitalize } }
                  td { link_to "View", helpers.verb_batch_path(batch), class: "button button--small button--secondary" }
                end
              end
            end
          end
        end
      end
    end
  end
end
