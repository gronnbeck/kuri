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
          "View all cards →",
          helpers.verb_transformation_exercises_path,
          class: "button mt-2",
          data:  { batch_progress_target: "viewLink" },
          style: @batch.done? ? "" : "display:none"
        )
      end

      items = @batch.batch_items.includes(:exercise).order(:id)
      render_items_table(items) if items.any?
    end
  end

  private

  def render_items_table(items)
    div(class: "batch-items") do
      h3(class: "batch-items-heading") { "Generated Cards" }
      div(class: "batch-items-list") do
        items.each_with_index do |item, i|
          div(class: "batch-item batch-item--#{item.status}") do
            span(class: "batch-item-num") { "##{i + 1}" }
            if item.completed? && item.exercise
              ex = item.exercise
              div(class: "batch-item-content") do
                span(class: "batch-item-jp") { ex.verb_jp }
                span(class: "batch-item-en") { ex.verb_en } if ex.verb_en.present?
                span(class: "badge badge--context") { ex.target_form_label }
              end
              link_to "View →", helpers.verb_transformation_exercise_path(ex), class: "button button--small button--ghost"
            elsif item.failed?
              span(class: "batch-item-failed") { "Failed" }
            else
              span(class: "batch-item-pending") { "Pending…" }
            end
          end
        end
      end
    end
  end
end
