# frozen_string_literal: true

class Views::Settings::Index < ApplicationView
  def view_template
    div(class: "page-header") do
      h1 { "Settings" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        render Views::Components::SettingsNavList.new(items: [
          { title: "Listen", description: "Manage actors and voices for audio clip generation", path: helpers.settings_listen_path }
        ])
      end
    end
  end
end
