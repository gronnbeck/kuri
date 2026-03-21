# frozen_string_literal: true

class Views::Settings::Index < ApplicationView
  def view_template
    div(class: "page-header") do
      h1 { "Settings" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        ul(class: "settings-nav-list") do
          li do
            link_to helpers.settings_listen_path, class: "settings-nav-item" do
              div(class: "settings-nav-title") { "Listen" }
              div(class: "settings-nav-desc") { "Manage actors and voices for audio clip generation" }
            end
          end
        end
      end
    end
  end
end
