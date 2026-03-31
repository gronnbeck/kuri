# frozen_string_literal: true

class Views::NoteEnrichmentBatches::Show < ApplicationView
  STATUS_LABELS = {
    "pending"   => "Pending",
    "running"   => "Enriching…",
    "reviewing" => "Ready to review",
    "pushing"   => "Pushing to Anki…",
    "completed" => "Completed",
    "failed"    => "Failed"
  }.freeze

  def initialize(batch:, enrichments:)
    @batch       = batch
    @enrichments = enrichments
  end

  def view_template
    div(class: "page-header") do
      div do
        render Views::Components::Breadcrumb.new(items: [
          { label: "Enrich Notes", path: helpers.note_enrichment_batches_path },
          { label: "Batch ##{@batch.id}" }
        ])
        h1 { "Enrichment Batch ##{@batch.id}" }
      end
    end

    div(class: "exercise-content") do
      div(class: "exercise-section",
          data: { controller: "enrichment-progress",
                  enrichment_progress_batch_id_value: @batch.id,
                  enrichment_progress_complete_value: @batch.done? || @batch.reviewing? }) do
        div(class: "batch-meta") do
          plain "#{@batch.deck_name} · "
          strong { "#{@batch.source_field} → #{@batch.destination_field}" }
          plain " · #{@batch.transformation}"
        end

        unless @batch.done?
          render_progress_section
        end

        render_review_section if @batch.reviewing? || @batch.completed? || @batch.pushing?
      end
    end
  end

  private

  def render_progress_section
    div(class: "batch-progress-section") do
      div(class: "batch-progress-counts") do
        plain "Enriched: "
        span(data: { enrichment_progress_target: "enriched" }) { @batch.enriched_count.to_s }
        plain " · Failed: "
        span(data: { enrichment_progress_target: "failed" }) { @batch.failed_count.to_s }
        plain " · Total: #{@batch.total}"
      end

      div(class: "batch-progress-bar-track") do
        div(class: "batch-progress-bar-fill",
            data: { enrichment_progress_target: "bar" },
            style: "width: #{@batch.progress_percent}%")
      end

      div(class: "batch-progress-status") do
        plain "Status: "
        span(data: { enrichment_progress_target: "status" }) { STATUS_LABELS[@batch.status] || @batch.status.capitalize }
      end
    end
  end

  def render_review_section
    enriched = @enrichments.select { |e| %w[enriched approved rejected].include?(e.status) }
    approved_count = @enrichments.count(&:approved?)

    div(class: "enrichment-review") do
      div(class: "enrichment-review-header") do
        h3 { "Review (#{enriched.size} notes)" }
        if @batch.reviewing?
          div(class: "button-group") do
            button_to "Approve all", helpers.approve_all_note_enrichment_batch_path(@batch),
              method: :post, class: "button button--small button--success"
            button_to "Reject all", helpers.reject_all_note_enrichment_batch_path(@batch),
              method: :post, class: "button button--small button--ghost"
          end
        end
      end

      if @batch.reviewing? && approved_count > 0
        div(class: "enrichment-push-bar") do
          plain "#{approved_count} approved · "
          button_to "Push #{approved_count} to Anki →",
            helpers.push_note_enrichment_batch_path(@batch),
            method: :post, class: "button"
        end
      end

      if @batch.completed?
        div(class: "enrichment-push-bar enrichment-push-bar--done") do
          plain "Pushed #{@batch.pushed_count} of #{@batch.total} notes to Anki."
        end
      end

      div(class: "enrichment-list") do
        enriched.each do |e|
          div(class: "enrichment-item enrichment-item--#{e.status}") do
            div(class: "enrichment-item-values") do
              div(class: "enrichment-item-source") { e.source_value }
              div(class: "enrichment-item-arrow") { "→" }
              div(class: "enrichment-item-result") do
                if e.failed?
                  span(class: "enrichment-item-error") { e.error_message }
                else
                  plain e.enriched_value.to_s
                end
              end
            end
            if @batch.reviewing? && !e.failed?
              div(class: "enrichment-item-actions") do
                if e.approved?
                  button_to "✓ Approved", helpers.reject_note_enrichment_path(@batch, e),
                    method: :post, class: "button button--small button--success"
                elsif e.rejected?
                  button_to "Approve", helpers.approve_note_enrichment_path(@batch, e),
                    method: :post, class: "button button--small button--ghost"
                else
                  button_to "Approve", helpers.approve_note_enrichment_path(@batch, e),
                    method: :post, class: "button button--small button--success"
                  button_to "Reject", helpers.reject_note_enrichment_path(@batch, e),
                    method: :post, class: "button button--small button--ghost"
                end
              end
            end
          end
        end
      end
    end
  end
end
