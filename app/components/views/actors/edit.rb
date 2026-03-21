# frozen_string_literal: true

class Views::Actors::Edit < ApplicationView
  def initialize(actor:)
    @actor = actor
  end

  def view_template
    div(class: "page-header") do
      div(class: "breadcrumb") do
        link_to "Settings", helpers.settings_path
        span { " › " }
        link_to "Listen", helpers.settings_listen_path
        span { " › " }
        link_to "Actors", helpers.settings_listen_actors_path
        span { " › " }
        span { "Edit" }
      end
      h1 { "Edit Actor" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        form(action: helpers.settings_listen_actor_path(@actor), method: "post", data: { turbo: "false" }) do
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
          input(type: "hidden", name: "_method", value: "patch")
          div(class: "actor-form-row") do
            input(type: "text", name: "name", placeholder: "Name (optional)", class: "micro-input", value: @actor.name.to_s, style: "width: 200px")
            input(type: "text", name: "voice_id", placeholder: "ElevenLabs Voice ID", class: "micro-input", value: @actor.voice_id, style: "flex: 1; font-family: monospace; font-size: 0.9rem;", required: true)
            button(type: "submit", class: "button") { "Save" }
          end
        end
      end
    end
  end
end
