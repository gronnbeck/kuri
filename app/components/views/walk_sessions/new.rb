# frozen_string_literal: true

class Views::WalkSessions::New < ApplicationView
  def initialize(session:)
    @session = session
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Walk & Talk", path: helpers.walk_sessions_path },
        { label: "New" }
      ])
      h1 { "New Walk & Talk Session" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        render_form(helpers.walk_sessions_path, "post")
      end
    end
  end

  private

  def render_form(action, method)
    form(action: action, method: method, data: { turbo: "false" }) do
      input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

      div(class: "form-group") do
        label(for: "walk_session_name") { "Session name" }
        input(type: "text", name: "walk_session[name]", id: "walk_session_name",
              class: "form-input", placeholder: "e.g. Morning commute", value: @session.name.to_s,
              autofocus: true)
      end

      div(class: "form-row") do
        div(class: "form-group") do
          label(for: "walk_session_inner_pause_ms") { "Pause between parts (ms)" }
          input(type: "number", name: "walk_session[inner_pause_ms]", id: "walk_session_inner_pause_ms",
                class: "form-input", value: @session.inner_pause_ms || 2000, min: 0, step: 500,
                style: "width: 160px")
          p(class: "form-hint") { "Gap between request and response within one exercise" }
        end

        div(class: "form-group") do
          label(for: "walk_session_outer_pause_ms") { "Pause between exercises (ms)" }
          input(type: "number", name: "walk_session[outer_pause_ms]", id: "walk_session_outer_pause_ms",
                class: "form-input", value: @session.outer_pause_ms || 4000, min: 0, step: 500,
                style: "width: 160px")
          p(class: "form-hint") { "Gap between different exercises" }
        end
      end

      button(type: "submit", class: "button") { "Create & build playlist" }
    end
  end
end
