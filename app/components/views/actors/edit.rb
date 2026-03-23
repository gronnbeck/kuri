# frozen_string_literal: true

class Views::Actors::Edit < ApplicationView
  def initialize(actor:)
    @actor = actor
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Settings", path: helpers.settings_path },
        { label: "Listen",   path: helpers.settings_listen_path },
        { label: "Actors",   path: helpers.settings_listen_actors_path },
        { label: "Edit" }
      ])
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
