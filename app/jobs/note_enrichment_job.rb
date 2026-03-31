# frozen_string_literal: true

class NoteEnrichmentJob < ApplicationJob
  queue_as :default

  def perform(batch_id)
    batch = NoteEnrichmentBatch.find(batch_id)
    batch.update!(status: :running)

    batch.note_enrichments.pending.order(:id).each do |enrichment|
      begin
        result = NoteEnricher.call(
          transformation: batch.transformation,
          source_value:   enrichment.source_value
        )
        enrichment.update!(status: :enriched, enriched_value: result)
        batch.increment!(:enriched_count)
      rescue => e
        enrichment.update!(status: :failed, error_message: e.message)
        batch.increment!(:failed_count)
      end

      ActionCable.server.broadcast(
        batch.stream_name,
        { type: "progress", enriched: batch.enriched_count,
          failed: batch.failed_count, total: batch.total }
      )
    end

    batch.update!(status: :reviewing)
    ActionCable.server.broadcast(batch.stream_name, { type: "ready_for_review" })
  rescue => e
    batch&.update!(status: :failed)
    ActionCable.server.broadcast(batch.stream_name, { type: "done" })
    raise
  end
end
