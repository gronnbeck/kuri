# frozen_string_literal: true

class Views::Settings::Listen < ApplicationView
  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Settings", path: helpers.settings_path },
        { label: "Listen" }
      ])
      h1 { "Listen" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        render Views::Components::SettingsNavList.new(items: [
          { title: "Actors",        description: "Manage voices used for audio clip generation",                path: helpers.settings_listen_actors_path },
          { title: "Conversations", description: "Configure Anki connection for conversation exercise export", path: helpers.settings_listen_conversations_path }
        ])
      end
    end
  end
end
