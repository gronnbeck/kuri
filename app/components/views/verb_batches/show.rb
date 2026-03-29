# frozen_string_literal: true

class Views::VerbBatches::Show < ApplicationView
  def initialize(batch:)
    @batch = batch
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Listen",       path: helpers.audio_clips_path },
        { label: "Verb Batches", path: helpers.verb_batches_path },
        { label: "Batch ##{@batch.id}" }
      ])
      h1 { "Verb Batch ##{@batch.id}" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section",
          data: { controller: "batch-progress",
                  batch_progress_batch_id_value: @batch.id,
                  batch_progress_complete_value: @batch.done? }) do
        div(class: "batch-meta") do
          span { "Difficulty: " }
          strong { @batch.difficulty.upcase }
          plain " · Target form: "
          strong do
            @batch.target_form.present? \
              ? VerbTransformationExercise::TARGET_FORM_LABELS[@batch.target_form]
              : "Random"
          end
        end

        div(class: "batch-progress-section") do
          div(class: "batch-progress-counts") do
            plain "Completed: "
            span(data: { batch_progress_target: "completed" }) { @batch.completed_count.to_s }
            plain " · Failed: "
            span(data: { batch_progress_target: "failed" }) { @batch.failed_count.to_s }
            plain " · Total: #{@batch.total}"
          end

          div(class: "batch-progress-bar-track") do
            div(class: "batch-progress-bar-fill",
                data: { batch_progress_target: "bar" },
                style: "width: #{@batch.progress_percent}%")
          end

          div(class: "batch-progress-status") do
            plain "Status: "
            span(data: { batch_progress_target: "status" }) { @batch.status.capitalize }
          end
        end

        link_to(
          "View generated cards →",
          helpers.verb_transformation_exercises_path,
          class: "button mt-2",
          data:  { batch_progress_target: "viewLink" },
          style: @batch.done? ? "" : "display:none"
        )
      end
    end
  end
end
