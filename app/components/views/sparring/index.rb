# frozen_string_literal: true

class Views::Sparring::Index < ApplicationView
  def initialize(conversations:, current_id:)
    @conversations = conversations
    @current_id    = current_id
  end

  def view_template
    div(class: "page-header") do
      h1 { "Sparring" }
      div(class: "header-actions") do
        a(href: helpers.sparring_path, class: "button") { "Current conversation" }
        a(href: helpers.new_conversation_sparring_path, class: "button button--secondary") { "New conversation" }
      end
    end

    if @conversations.empty?
      p(class: "muted") { "No conversations yet." }
    else
      div(class: "sparring-index") do
        @conversations.each do |conv|
          is_current = conv.id == @current_id
          div(class: "sparring-index-row #{"sparring-index-row--current" if is_current}") do
            a(href: helpers.resume_sparring_path(conv), class: "sparring-index-link") do
              div(class: "sparring-index-preview") do
                plain(conv.first_message.to_s.truncate(120))
              end
              div(class: "sparring-index-meta") do
                span { "#{conv.message_count} #{"message".pluralize(conv.message_count)}" }
                span { " · " }
                span { helpers.time_ago_in_words(conv.updated_at) + " ago" }
                span { " · current" } if is_current
              end
            end
          end
        end
      end
    end
  end
end
