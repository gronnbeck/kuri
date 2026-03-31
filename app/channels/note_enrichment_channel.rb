# frozen_string_literal: true

class NoteEnrichmentChannel < ApplicationCable::Channel
  def subscribed
    batch = NoteEnrichmentBatch.find_by(id: params[:batch_id])
    if batch
      stream_from batch.stream_name
    else
      reject
    end
  end
end
