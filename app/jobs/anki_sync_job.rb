# frozen_string_literal: true

class AnkiSyncJob < ApplicationJob
  queue_as :default

  # mode: :fetch_new — import only notes not yet in the local DB (default)
  #       :resync    — import new notes AND update fields/tags on existing ones
  def perform(mode: :fetch_new)
    client = AnkiConnect::Client.new

    Deck.sync_enabled.each do |deck|
      sync_deck(client, deck, mode: mode.to_sym)
      deck.update!(last_synced_at: Time.current)
    end
  end

  private

  def sync_deck(client, deck, mode:)
    all_ids      = client.find_notes(deck: deck.name)
    existing_ids = deck.notes.where(anki_id: all_ids).pluck(:anki_id)
    new_ids      = all_ids - existing_ids

    ids_to_fetch = mode == :resync ? all_ids : new_ids
    return if ids_to_fetch.empty?

    client.notes_info(ids: ids_to_fetch).each do |data|
      note = deck.notes.find_or_initialize_by(anki_id: data["noteId"])
      note.fields = data["fields"]
      note.tags   = data["tags"]
      note.save!
    end
  end
end
