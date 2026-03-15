# frozen_string_literal: true

class Views::Notes::Index < ApplicationView
  def initialize(notes:, page:, total_pages:)
    @notes = notes
    @page = page
    @total_pages = total_pages
  end

  def view_template
    h1 { "Notes" }
    div(class: "notes-grid") do
      @notes.each do |note|
        render Views::Notes::NoteCard.new(note: note)
      end
    end
    render_pagination
  end

  private

  def render_pagination
    return if @total_pages <= 1

    nav(class: "pagination") do
      if @page > 1
        a(href: helpers.notes_path(page: @page - 1)) { "← Previous" }
      end
      span(class: "pagination-info") { "Page #{@page} of #{@total_pages}" }
      if @page < @total_pages
        a(href: helpers.notes_path(page: @page + 1)) { "Next →" }
      end
    end
  end
end
