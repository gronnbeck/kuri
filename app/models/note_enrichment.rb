# frozen_string_literal: true

class NoteEnrichment < ApplicationRecord
  belongs_to :note_enrichment_batch

  enum :status, {
    pending:  "pending",
    enriched: "enriched",
    approved: "approved",
    rejected: "rejected",
    pushed:   "pushed",
    failed:   "failed"
  }

  validates :anki_note_id, presence: true
end
