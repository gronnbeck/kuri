# frozen_string_literal: true

class NotesController < ApplicationController
  PER_PAGE = 20

  def index
    page = [ params.fetch(:page, 1).to_i, 1 ].max
    scope = Note.order(created_at: :desc)
    total_pages = [ (scope.count / PER_PAGE.to_f).ceil, 1 ].max
    page = [ page, total_pages ].min
    notes = scope.offset((page - 1) * PER_PAGE).limit(PER_PAGE)
    render ::Views::Notes::Index.new(notes: notes, page: page, total_pages: total_pages)
  end

  def show
    note = Note.find_by!(anki_id: params[:id])
    render ::Views::Notes::Show.new(note: note)
  rescue ActiveRecord::RecordNotFound
    redirect_to notes_path, alert: "Note not found."
  end

  def fields
    note = Note.find_by!(anki_id: params[:id])
    fields = note.fields.transform_values { |f| f["value"].to_s }
    render json: { note_id: note.anki_id, fields: fields }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Note #{params[:id]} not found. Make sure it has been synced." }, status: :not_found
  end

  def push_to_anki
    note = Note.find_by!(anki_id: params[:id])
    fields = note.fields.transform_values { |f| f["value"].to_s }
    AnkiConnect::Client.new.update_note_fields(note.anki_id, fields)
    redirect_to note_path(note.anki_id), notice: "Note pushed to Anki."
  rescue ActiveRecord::RecordNotFound
    redirect_to notes_path, alert: "Note not found."
  rescue AnkiConnect::Client::ConnectionError => e
    redirect_to note_path(params[:id]), alert: "Anki unavailable: #{e.message}"
  rescue => e
    redirect_to note_path(params[:id]), alert: "Failed: #{e.message}"
  end
end
