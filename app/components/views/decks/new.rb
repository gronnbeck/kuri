# frozen_string_literal: true

class Views::Decks::New < ApplicationView
  def initialize(available_decks:)
    @available_decks = available_decks
  end

  def view_template
    a(href: helpers.decks_path) { "← Back to decks" }
    h1 { "Add deck" }

    if @available_decks.empty?
      p { "All Anki decks have already been added." }
    else
      form(action: helpers.decks_path, method: "post") do
        input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
        div(class: "form-group") do
          label(for: "name") { "Select a deck" }
          select(name: "name", id: "name") do
            @available_decks.each do |deck_name|
              option(value: deck_name) { deck_name }
            end
          end
        end
        button(type: "submit") { "Add deck" }
      end
    end
  end
end
