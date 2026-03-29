# frozen_string_literal: true

class Views::Actors::Index < ApplicationView
  def initialize(actors:)
    @actors = actors
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Settings", path: helpers.settings_path },
        { label: "Listen",   path: helpers.settings_listen_path },
        { label: "Actors" }
      ])
      h1 { "Actors" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        h2 { "Add Actor" }
        form(action: helpers.settings_listen_actors_path, method: "post", data: { turbo: "false" }) do
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
          div(class: "actor-form-row") do
            input(type: "text", name: "name", placeholder: "Name (optional)", class: "micro-input", style: "width: 200px")
            input(type: "text", name: "voice_id", placeholder: "ElevenLabs Voice ID", class: "micro-input", style: "flex: 1; font-family: monospace; font-size: 0.9rem;", required: true)
            select(name: "gender", class: "form-select") do
              option(value: "") { "— gender —" }
              option(value: "female") { "Female" }
              option(value: "male") { "Male" }
            end
            button(type: "submit", class: "button") { "Add" }
          end
        end
      end

      div(class: "exercise-section") do
        h2 { "All Actors" }
        if @actors.empty?
          p(class: "exercise-instructions") { "No actors yet." }
        else
          table(class: "actor-table") do
            thead do
              tr do
                th { "Name" }
                th { "Gender" }
                th { "Voice ID" }
                th { "Clips" }
                th { "" }
              end
            end
            tbody do
              @actors.each do |actor|
                tr do
                  td { actor.display_name }
                  td { actor.gender.to_s.capitalize.presence || "—" }
                  td { code { actor.voice_id } }
                  td { actor.clips.size.to_s }
                  td(class: "actor-table-actions") do
                    link_to "Edit", helpers.edit_settings_listen_actor_path(actor), class: "button button--secondary button--small"
                    form(action: helpers.settings_listen_actor_path(actor), method: "post", style: "display:inline", data: { turbo: "false" }) do
                      input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
                      input(type: "hidden", name: "_method", value: "delete")
                      button(type: "submit", class: "button button--secondary button--small") { "Remove" }
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
