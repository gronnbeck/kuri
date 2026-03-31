# frozen_string_literal: true

class Views::NoteEnrichmentBatches::Index < ApplicationView
  def initialize(batches:)
    @batches = batches
  end

  def view_template
    div(class: "page-header") do
      div do
        h1 { "Enrich Anki Notes" }
      end
      link_to "Try single", helpers.try_single_note_enrichments_path, class: "button button--ghost"
      link_to "New batch enrichment", helpers.new_note_enrichment_batch_path, class: "button"
    end

    if @batches.any?
      div(class: "batch-items-list mt-2") do
        @batches.each do |batch|
          div(class: "batch-item batch-item--#{batch.status}") do
            div(class: "batch-item-content") do
              span(class: "batch-item-jp") { "#{batch.deck_name} · #{batch.source_field} → #{batch.destination_field}" }
              span(class: "batch-item-en") do
                "#{batch.transformation} · #{batch.total} notes · #{batch.status.capitalize}"
              end
            end
            link_to "View →", helpers.note_enrichment_batch_path(batch), class: "button button--small button--ghost"
          end
        end
      end
    else
      p(class: "empty-state") { "No enrichment batches yet." }
    end
  end
end
