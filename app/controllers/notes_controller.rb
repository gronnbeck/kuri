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
end
