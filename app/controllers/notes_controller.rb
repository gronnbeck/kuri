# frozen_string_literal: true

class NotesController < ApplicationController
  DECK = "Personal mining"

  def index
    client = AnkiConnect::Client.new
    ids = client.find_notes(deck: DECK)
    @notes = client.notes_info(ids: ids)
  end
end
