# frozen_string_literal: true

class Views::AudioClips::Index < ApplicationView
  def initialize(actors:, sentences:)
    @actors    = actors
    @sentences = sentences
  end

  def view_template
    div(class: "page-header") do
      h1 { "Listen" }
    end

    div(class: "exercise-content") do
      render_generate_form
      render_sentences_section
    end
  end

  private

  def render_generate_form
    div(class: "exercise-section") do
      h2 { "Generate Clip" }

      if @actors.empty?
        p(class: "exercise-instructions") do
          plain "No actors yet. "
          link_to "Add one →", helpers.settings_listen_actors_path
        end
      else
        form(action: helpers.audio_clips_path, method: "post", data: { turbo: "false" }) do
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
          div(class: "audio-generate-row") do
            input(
              type: "text",
              name: "text",
              placeholder: "例：今日はいい天気ですね。",
              class: "micro-input",
              required: true,
              autofocus: true,
              style: "flex: 1; font-size: 1.1rem;"
            )
            select(name: "actor_id", class: "actor-select") do
              @actors.each do |actor|
                option(value: actor.id) { actor.display_name }
              end
            end
            button(type: "submit", class: "button") { "Generate" }
          end
        end
      end
    end
  end

  def render_sentences_section
    return unless @sentences.any?

    div(class: "exercise-section") do
      h2 { "Sentences" }
      ul(class: "audio-clip-list") do
        @sentences.each do |sentence|
          li(class: "audio-clip-item") do
            div(class: "audio-clip-text jp") { sentence.text }
            div(class: "audio-clip-voices") do
              sentence.clips.each do |clip|
                div(class: "audio-clip-voice-row") do
                  span(class: "audio-clip-actor") { clip.actor.display_name }
                  audio(
                    controls: true,
                    src: helpers.audio_audio_clip_path(clip),
                    class: "audio-player",
                    preload: "none"
                  )
                end
              end
            end
          end
        end
      end
    end
  end
end
