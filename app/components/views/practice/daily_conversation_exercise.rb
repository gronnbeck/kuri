# frozen_string_literal: true

class Views::Practice::DailyConversationExercise < ApplicationView
  def initialize(theme_key:, theme:, history:, current_staff_line:, scenario_complete:)
    @theme_key        = theme_key
    @theme            = theme
    @history          = history
    @current_staff_line = current_staff_line
    @scenario_complete  = scenario_complete
  end

  def view_template
    div(class: "page-header") do
      h1 { "#{@theme[:emoji]} #{@theme[:name]}" }
      link_to "← Exit", helpers.practice_daily_conversations_path, class: "button button--secondary"
    end

    p(class: "conv-scenario") { @theme[:description] }

    div(class: "conv-thread") do
      @history.each do |turn|
        if turn["role"] == "staff"
          render_staff_bubble(turn)
        else
          render_customer_bubble(turn)
        end
      end

      if @scenario_complete
        div(class: "conv-complete") do
          div(class: "conv-complete-icon") { "✓" }
          div(class: "conv-complete-text") { "Conversation complete!" }
          link_to "Try another scenario", helpers.practice_daily_conversations_path, class: "button"
        end
      elsif @current_staff_line
        render_staff_bubble(@current_staff_line)
        render_input_form
      end
    end
  end

  private

  def render_staff_bubble(turn)
    div(class: "conv-bubble conv-bubble--staff") do
      div(class: "conv-bubble-jp") { turn["jp"] }
      div(class: "conv-bubble-furigana") { turn["furigana"] } if turn["furigana"].present?
      div(class: "conv-bubble-en") { turn["en"] }
    end
  end

  def render_customer_bubble(turn)
    div(class: "conv-bubble conv-bubble--customer") do
      div(class: "conv-bubble-jp") { turn["jp"] }
    end
    if turn["feedback"].present?
      css = turn["correct"] ? "conv-feedback conv-feedback--correct" : "conv-feedback conv-feedback--incorrect"
      div(class: css) { turn["feedback"] }
    end
  end

  def render_input_form
    form(
      action: helpers.check_daily_conversation_path,
      method: "post",
      data: { turbo: "false" },
      class: "conv-form"
    ) do
      input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
      input(type: "hidden", name: "theme_key", value: @theme_key)
      input(type: "hidden", name: "history", value: @history.to_json)
      input(type: "hidden", name: "current_staff_line_jp", value: @current_staff_line["jp"])
      input(type: "hidden", name: "current_staff_line_en", value: @current_staff_line["en"])
      input(type: "hidden", name: "current_staff_line_furigana", value: @current_staff_line["furigana"])

      textarea(
        class: "practice-input",
        name: "answer",
        placeholder: "Reply in Japanese...",
        rows: 2,
        autofocus: true
      )
      div(class: "sp-form-actions") do
        button(type: "submit", class: "button") { "Send" }
      end
    end
  end
end
