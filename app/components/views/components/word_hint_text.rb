# frozen_string_literal: true

# Renders an English text block where each word is wrapped in a clickable span
# that hooks into the word-hint Stimulus controller.
#
# Usage:
#   render Views::Components::WordHintText.new(text: "I drink coffee.")
class Views::Components::WordHintText < ApplicationView
  def initialize(text:)
    @text = text
  end

  def view_template
    div(class: "sp-english", data: { controller: "word-hint" }) do
      @text.split(" ").each_with_index do |token, i|
        plain " " if i > 0
        bare_word = token.gsub(/\A[^a-zA-Z0-9]+|[^a-zA-Z0-9]+\z/, "")
        span(
          class: "sp-word",
          data: {
            word_hint_target: "word",
            action: "click->word-hint#lookup",
            word: bare_word
          }
        ) { token }
      end
    end
  end
end
