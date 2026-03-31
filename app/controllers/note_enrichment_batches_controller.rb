# frozen_string_literal: true

class NoteEnrichmentBatchesController < ApplicationController
  before_action :set_batch, only: [ :show, :approve_all, :reject_all, :push ]

  def index
    @batches = NoteEnrichmentBatch.order(created_at: :desc)
    render Views::NoteEnrichmentBatches::Index.new(batches: @batches)
  end

  def new
    render Views::NoteEnrichmentBatches::New.new
  end

  def create
    deck_name        = params[:deck_name].presence
    note_type        = params[:note_type].presence
    source_field     = params[:source_field].presence
    destination_field = params[:destination_field].presence
    transformation   = params[:transformation].presence

    unless deck_name && note_type && source_field && destination_field && transformation
      redirect_to new_note_enrichment_batch_path, alert: "All fields are required."
      return
    end

    client = AnkiConnect::Client.new
    note_ids = client.find_notes(deck: deck_name)

    if note_ids.empty?
      redirect_to new_note_enrichment_batch_path, alert: "No notes found in deck '#{deck_name}'."
      return
    end

    notes_data = client.notes_info(ids: note_ids)

    batch = NoteEnrichmentBatch.create!(
      deck_name:         deck_name,
      note_type:         note_type,
      source_field:      source_field,
      destination_field: destination_field,
      transformation:    transformation,
      total:             notes_data.size
    )

    notes_data.each do |note|
      source_value = note.dig("fields", source_field, "value").to_s
      batch.note_enrichments.create!(
        anki_note_id: note["noteId"],
        source_value: source_value
      )
    end

    NoteEnrichmentJob.perform_later(batch.id)
    redirect_to note_enrichment_batch_path(batch)
  rescue AnkiConnect::Client::ConnectionError => e
    redirect_to new_note_enrichment_batch_path, alert: "Anki unavailable: #{e.message}"
  rescue => e
    redirect_to new_note_enrichment_batch_path, alert: "Failed: #{e.message}"
  end

  def show
    @enrichments = @batch.note_enrichments.order(:id)
    render Views::NoteEnrichmentBatches::Show.new(batch: @batch, enrichments: @enrichments)
  end

  def approve_all
    @batch.note_enrichments.enriched.update_all(status: "approved")
    @batch.update!(approved_count: @batch.note_enrichments.approved.count)
    redirect_to note_enrichment_batch_path(@batch), notice: "All enriched notes approved."
  end

  def reject_all
    @batch.note_enrichments.enriched.update_all(status: "rejected")
    redirect_to note_enrichment_batch_path(@batch), notice: "All enriched notes rejected."
  end

  def push
    unless @batch.reviewing?
      redirect_to note_enrichment_batch_path(@batch), alert: "Batch is not in review state."
      return
    end

    @batch.update!(status: :pushing)
    client = AnkiConnect::Client.new
    approved = @batch.note_enrichments.approved

    approved.each do |enrichment|
      begin
        client.update_note_fields(
          enrichment.anki_note_id,
          { @batch.destination_field => enrichment.enriched_value }
        )
        enrichment.update!(status: :pushed)
        @batch.increment!(:pushed_count)
      rescue => e
        enrichment.update!(status: :failed, error_message: e.message)
        @batch.increment!(:failed_count)
      end
    end

    @batch.update!(status: :completed)
    redirect_to note_enrichment_batch_path(@batch), notice: "Pushed #{@batch.pushed_count} notes to Anki."
  rescue AnkiConnect::Client::ConnectionError => e
    @batch.update!(status: :failed)
    redirect_to note_enrichment_batch_path(@batch), alert: "Anki unavailable: #{e.message}"
  end

  private

  def set_batch
    @batch = NoteEnrichmentBatch.find(params[:id])
  end
end
