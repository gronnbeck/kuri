# frozen_string_literal: true

class Views::WalkSessions::Index < ApplicationView
  def initialize(sessions:)
    @sessions = sessions
  end

  def view_template
    div(class: "page-header") do
      h1 { "Walk & Talk" }
      a(href: helpers.new_walk_session_path, class: "button") { "New session" }
    end

    if @sessions.empty?
      p(class: "muted") { "No sessions yet. Create one to get started." }
    else
      div(class: "ce-list") do
        @sessions.each do |s|
          div(class: "ce-list-item") do
            a(href: helpers.walk_session_path(s), class: "ce-list-link") do
              div(class: "ce-list-main") do
                span(class: "ce-list-text") { s.name }
                span(class: "ce-list-text--jp", style: "font-size:0.85rem;color:#888") do
                  "#{s.walk_session_items.count} items · #{s.inner_pause_ms / 1000.0}s / #{s.outer_pause_ms / 1000.0}s pauses"
                end
              end
              div(class: "ce-list-meta") do
                span(class: "badge #{"badge--audio" if s.ready?}") { s.status }
              end
            end
          end
        end
      end
    end
  end
end
