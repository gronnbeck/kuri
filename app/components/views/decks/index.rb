# frozen_string_literal: true

class Views::Decks::Index < ApplicationView
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(decks:)
    @decks = decks
  end

  def view_template
    div(class: "page-header") do
      h1 { "Decks" }
      div(class: "header-actions") do
        button_to "Sync now", helpers.sync_decks_path, method: :post, class: "button button--secondary"
        a(href: helpers.new_deck_path, class: "button") { "Add deck" }
      end
    end

    if @decks.empty?
      p { "No decks added yet." }
    else
      table(class: "decks-table") do
        thead do
          tr do
            th { "Name" }
            th { "Sync" }
            th { "Last synced" }
            th { "Notes" }
            th
          end
        end
        tbody do
          @decks.each do |deck|
            tr do
              td { deck.name }
              td do
                button_to deck.sync_enabled ? "Disable" : "Enable",
                  helpers.deck_path(deck),
                  method: :patch,
                  params: { sync_enabled: deck.sync_enabled ? "0" : "1" }
              end
              td { deck.last_synced_at&.strftime("%b %d, %H:%M") || "Never" }
              td { deck.notes.count.to_s }
              td do
                button_to "Remove", helpers.deck_path(deck), method: :delete,
                  data: { turbo_confirm: "Remove #{deck.name}?" }
              end
            end
          end
        end
      end
    end
  end
end
