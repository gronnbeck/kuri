# frozen_string_literal: true

class Views::Settings::Listen < ApplicationView
  def view_template
    div(class: "page-header") do
      div(class: "breadcrumb") do
        link_to "Settings", helpers.settings_path
        span { " › " }
        span { "Listen" }
      end
      h1 { "Listen" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        ul(class: "settings-nav-list") do
          li do
            link_to helpers.settings_listen_actors_path, class: "settings-nav-item" do
              div(class: "settings-nav-title") { "Actors" }
              div(class: "settings-nav-desc") { "Manage voices used for audio clip generation" }
            end
          end
        end
      end
    end
  end
end
