# frozen_string_literal: true

class NoteEnrichmentsController < ApplicationController
  before_action :set_batch_and_enrichment, only: [ :approve, :reject ]

  # Single-note enrichment: transform one piece of text and optionally save
  # the result back to an Anki note field.
  def try_single
    @transformation  = params[:transformation].presence || "reading"
    @source_text     = params[:source_text].to_s
    @anki_note_id    = params[:anki_note_id].presence
    @field_name      = params[:field_name].presence
    @result          = nil
    @error           = nil

    if request.post? && @source_text.present?
      begin
        @result = NoteEnricher.call(transformation: @transformation, source_value: @source_text)
      rescue => e
        @error = e.message
      end
    end

    render Views::NoteEnrichments::TrySingle.new(
      transformation: @transformation,
      source_text:    @source_text,
      anki_note_id:   @anki_note_id,
      field_name:     @field_name,
      result:         @result,
      error:          @error
    )
  end

  # Save the enriched value back to an Anki note field.
  def save_to_anki
    note_id    = params[:anki_note_id].to_i
    field_name = params[:field_name].presence
    value      = params[:value].presence

    unless note_id > 0 && field_name && value
      redirect_to try_single_note_enrichments_path, alert: "Missing note ID, field name, or value."
      return
    end

    client = AnkiConnect::Client.new
    client.update_note_fields(note_id, { field_name => value })
    redirect_to try_single_note_enrichments_path, notice: "Saved to Anki note #{note_id} field '#{field_name}'."
  rescue AnkiConnect::Client::ConnectionError => e
    redirect_to try_single_note_enrichments_path, alert: "Anki unavailable: #{e.message}"
  rescue => e
    redirect_to try_single_note_enrichments_path, alert: "Failed: #{e.message}"
  end

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
