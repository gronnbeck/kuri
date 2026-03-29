# frozen_string_literal: true

class Views::AudioClips::Index < ApplicationView
  def view_template
    div(class: "page-header") do
      h1 { "Listen" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        render Views::Components::SettingsNavList.new(items: [
          { title: "Generate Clip",           description: "Generate and replay Japanese audio clips",                            path: helpers.audio_clips_generate_path },
          { title: "Conversation Exercises",  description: "Author and review Japanese conversation cards, export to Anki",     path: helpers.conversation_exercises_path },
          { title: "Verb Exercises",          description: "Drill Japanese verb conjugation, export to Anki",                      path: helpers.verb_transformation_exercises_path }
        ])
      end
    end
  end
end
