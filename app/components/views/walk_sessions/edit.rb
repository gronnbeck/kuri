# frozen_string_literal: true

class Views::WalkSessions::Edit < ApplicationView
  def initialize(session:)
    @session = session
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Walk & Talk",    path: helpers.walk_sessions_path },
        { label: @session.name,    path: helpers.walk_session_path(@session) },
        { label: "Edit" }
      ])
      h1 { "Edit Session" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        form(action: helpers.walk_session_path(@session), method: "post", data: { turbo: "false" }) do
          input(type: "hidden", name: "_method",            value: "patch")
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

          div(class: "form-group") do
            label(for: "walk_session_name") { "Session name" }
            input(type: "text", name: "walk_session[name]", id: "walk_session_name",
                  class: "form-input", value: @session.name.to_s)
          end

          div(class: "form-row") do
            div(class: "form-group") do
              label { "Pause between parts (ms)" }
              input(type: "number", name: "walk_session[inner_pause_ms]", class: "form-input",
                    value: @session.inner_pause_ms, min: 0, step: 500, style: "width: 160px")
            end
            div(class: "form-group") do
              label { "Pause between exercises (ms)" }
              input(type: "number", name: "walk_session[outer_pause_ms]", class: "form-input",
                    value: @session.outer_pause_ms, min: 0, step: 500, style: "width: 160px")
            end
          end

          div(class: "header-actions") do
            button(type: "submit", class: "button") { "Save" }
            a(href: helpers.walk_session_path(@session), class: "button button--secondary") { "Cancel" }
          end
        end
      end
    end
  end
end
