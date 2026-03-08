# frozen_string_literal: true

class NotesController < ApplicationController
  DECK = "Personal mining"

  def index
    client = AnkiConnect::Client.new
    ids = client.find_notes(deck: DECK)
    @notes = client.notes_info(ids: ids)
  rescue AnkiConnect::Client::ConnectionError => e
    flash.now[:alert] = "AnkiConnect unavailable: #{e.message}"
    @notes = []
  end
end
