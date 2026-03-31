# frozen_string_literal: true

class NoteEnrichmentsController < ApplicationController
  before_action :set_batch_and_enrichment, only: [ :approve, :reject ]

  # Single-note enrichment: transform one piece of text and optionally save
  # the result back to an Anki note field.
  def try_single
    @transformation    = params[:transformation].presence || "reading"
    @custom_prompt     = params[:custom_prompt].to_s
    @source_text       = params[:source_text].to_s
    @anki_note_id      = params[:anki_note_id].presence
    @field_name        = params[:field_name].presence
    @target_field_name = params[:target_field_name].presence
    @result            = nil
    @error             = nil

    if request.post? && @source_text.present?
      begin
        @result = NoteEnricher.call(
          transformation: @transformation,
          source_value:   @source_text,
          custom_prompt:  @custom_prompt.presence
        )
      rescue => e
        @error = e.message
      end
    end

    render Views::NoteEnrichments::TrySingle.new(
      transformation:    @transformation,
      custom_prompt:     @custom_prompt,
      source_text:       @source_text,
      anki_note_id:      @anki_note_id,
      field_name:        @field_name,
      target_field_name: @target_field_name,
      result:            @result,
      error:             @error
    )
  end

  # Save the enriched value to the local Note record.
  # Use Resync (Decks page) to push the change to Anki afterwards.
  def save_to_note
    note_id    = params[:anki_note_id].to_i
    field_name = params[:field_name].presence
    value      = params[:value].presence

    unless note_id > 0 && field_name && value
      redirect_to try_single_note_enrichments_path, alert: "Missing note ID, field name, or value."
      return
    end

    note = Note.find_by!(anki_id: note_id)
    unless note.fields.key?(field_name)
      redirect_to try_single_note_enrichments_path, alert: "Field '#{field_name}' not found on note #{note_id}."
      return
    end

    note.fields[field_name]["value"] = value
    note.save!

    redirect_to note_path(note_id), notice: "Field '#{field_name}' saved. Use Resync on the Decks page to push to Anki."
  rescue ActiveRecord::RecordNotFound
    redirect_to try_single_note_enrichments_path, alert: "Note #{note_id} not found — sync it first."
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
