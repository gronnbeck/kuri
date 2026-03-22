# frozen_string_literal: true

class Views::AudioClips::Index < ApplicationView
  def view_template
    div(class: "page-header") do
      h1 { "Listen" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        ul(class: "settings-nav-list") do
          li do
            link_to helpers.audio_clips_generate_path, class: "settings-nav-item" do
              div(class: "settings-nav-title") { "Generate Clip" }
              div(class: "settings-nav-desc") { "Generate and replay Japanese audio clips" }
            end
          end
        end
      end
    end
  end
end
