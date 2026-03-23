# frozen_string_literal: true

# Renders the ul.settings-nav-list used on settings and listen index pages.
#
# Usage:
#   render Views::Components::SettingsNavList.new(items: [
#     { title: "Actors", description: "Manage voices", path: helpers.settings_listen_actors_path },
#     { title: "Conversations", description: "Anki export config", path: helpers.settings_listen_conversations_path }
#   ])
class Views::Components::SettingsNavList < ApplicationView
  def initialize(items:)
    @items = items
  end

  def view_template
    ul(class: "settings-nav-list") do
      @items.each do |item|
        li do
          link_to item[:path], class: "settings-nav-item" do
            div(class: "settings-nav-title") { item[:title] }
            div(class: "settings-nav-desc")  { item[:description] }
          end
        end
      end
    end
  end
end
