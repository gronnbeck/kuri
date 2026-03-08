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

  def show
    client = AnkiConnect::Client.new
    results = client.notes_info(ids: [ params[:id].to_i ])
    @note = results.first
  rescue AnkiConnect::Client::ConnectionError => e
    flash.now[:alert] = "AnkiConnect unavailable: #{e.message}"
    @note = nil
  end
end
