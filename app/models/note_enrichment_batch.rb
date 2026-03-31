# frozen_string_literal: true

class NoteEnrichmentBatch < ApplicationRecord
  has_many :note_enrichments, dependent: :destroy

  TRANSFORMATIONS = %w[reading translate furigana].freeze

  enum :status, {
    pending:   "pending",
    running:   "running",
    reviewing: "reviewing",
    pushing:   "pushing",
    completed: "completed",
    failed:    "failed"
  }

  validates :deck_name, :note_type, :source_field, :destination_field, :transformation, presence: true
  validates :transformation, inclusion: { in: TRANSFORMATIONS }

  def done?
    completed? || failed?
  end

  def stream_name
    "note_enrichment_batch_#{id}"
  end

  def progress_percent
    return 0 if total.zero?
    ((enriched_count + failed_count).to_f / total * 100).round
  end

  def pending_review_count
    note_enrichments.enriched.count
  end
end
