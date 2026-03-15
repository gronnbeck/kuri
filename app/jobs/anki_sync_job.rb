# frozen_string_literal: true

class AnkiSyncJob < ApplicationJob
  queue_as :default

  def perform
    client = AnkiConnect::Client.new

    Deck.sync_enabled.each do |deck|
      sync_deck(client, deck)
      deck.update!(last_synced_at: Time.current)
    end
  end

  private

  def sync_deck(client, deck)
    all_ids = client.find_notes(deck: deck.name)
    existing_ids = deck.notes.where(anki_id: all_ids).pluck(:anki_id)
    new_ids = all_ids - existing_ids

    return if new_ids.empty?

    client.notes_info(ids: new_ids).each do |data|
      deck.notes.create!(
        anki_id: data["noteId"],
        fields: data["fields"],
        tags: data["tags"]
      )
    end
  end
end
