# frozen_string_literal: true

class Views::Sparring::Show < ApplicationView
  def initialize(conversation:, error: nil)
    @conversation = conversation
    @error        = error
  end

  def view_template
    div(class: "page-header") do
      h1 { "Sparring" }
      p(class: "sparring-subtitle") { "Ask questions about your Kuri data. The AI can see your exercises and contexts." }
    end

    div(class: "sparring-layout") do
      div(class: "sparring-chat") do
        if @error
          div(class: "flash flash--alert") { "Error: #{@error}" }
        end

        history = @conversation.history

        if history.any?
          div(class: "sparring-messages") do
            history.each do |turn|
              if turn["role"] == "user"
                div(class: "sparring-message sparring-message--user") do
                  div(class: "sparring-message-label") { "You" }
                  div(class: "sparring-message-body") { turn["content"] }
                end
              else
                div(class: "sparring-message sparring-message--assistant") do
                  div(class: "sparring-message-label") { "Kuri AI" }
                  div(class: "sparring-message-body sparring-message-body--pre") { turn["content"] }
                end
              end
            end
          end
        else
          div(class: "sparring-empty") do
            p { "Ask anything about your Japanese learning data." }
            p(class: "sparring-examples-label") { "Examples:" }
            ul(class: "sparring-examples") do
              li { "Give me 10 beginner N5 words I can add to conversations — check they're not already there" }
              li { "What contexts do I have the most exercises for?" }
              li { "Suggest 5 new N4 conversation scenarios I haven't covered yet" }
            end
          end
        end

        form(action: helpers.sparring_chat_path, method: "post", class: "sparring-form", data: { turbo: "false" }) do
          input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
          div(class: "sparring-input-row") do
            input(
              type: "text",
              name: "message",
              class: "sparring-input",
              placeholder: "Ask something…",
              autofocus: true
            )
            button(type: "submit", class: "button") { "Send" }
          end
        end

        if history.any?
          div(class: "sparring-actions") do
            a(href: helpers.new_conversation_sparring_path, class: "button button--secondary") { "New conversation" }
          end
        end
      end
    end
  end
end
