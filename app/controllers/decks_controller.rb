# frozen_string_literal: true

class DecksController < ApplicationController
  def index
    @decks = Deck.order(:name)
    render ::Views::Decks::Index.new(decks: @decks)
  end

  def new
    client = AnkiConnect::Client.new
    anki_names = client.deck_names
    existing_names = Deck.pluck(:name)
    available = anki_names - existing_names
    render ::Views::Decks::New.new(available_decks: available)
  rescue AnkiConnect::Client::ConnectionError => e
    redirect_to decks_path, alert: "AnkiConnect unavailable: #{e.message}"
  end

  def create
    Deck.create!(name: params.require(:name))
    redirect_to decks_path, notice: "Deck added."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_deck_path, alert: e.message
  end

  def update
    deck = Deck.find(params[:id])
    deck.update!(sync_enabled: params[:sync_enabled] == "1")
    redirect_to decks_path
  end

  def sync
    AnkiSyncJob.perform_later
    redirect_to decks_path, notice: "Sync queued."
  end

  def destroy
    Deck.find(params[:id]).destroy!
    redirect_to decks_path, notice: "Deck removed."
  end
end
