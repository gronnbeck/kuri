# frozen_string_literal: true

class NoteEnrichmentsController < ApplicationController
  before_action :set_batch_and_enrichment

  def approve
    @enrichment.update!(status: :approved)
    @batch.update!(approved_count: @batch.note_enrichments.approved.count)
    redirect_to note_enrichment_batch_path(@batch)
  end

  def reject
    @enrichment.update!(status: :rejected)
    @batch.update!(approved_count: @batch.note_enrichments.approved.count)
    redirect_to note_enrichment_batch_path(@batch)
  end

  private

  def set_batch_and_enrichment
    @batch      = NoteEnrichmentBatch.find(params[:note_enrichment_batch_id])
    @enrichment = @batch.note_enrichments.find(params[:id])
  end
end
