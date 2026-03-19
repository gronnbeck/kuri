# frozen_string_literal: true

class Views::Practice::DailyConversations < ApplicationView
  THEMES = {
    "restaurant" => {
      name:        "Restaurant",
      emoji:       "🍱",
      description: "Be seated, order food, ask for the bill.",
      scenario:    "A customer walks into a Japanese restaurant. Guide them through: being greeted and seated, ordering food and drinks, receiving the meal, and paying the bill."
    },
    "konbini" => {
      name:        "Convenience Store",
      emoji:       "🏪",
      description: "Pay at the register, get a bag, use a points card.",
      scenario:    "A customer is shopping at a Japanese convenience store. Guide them through: being greeted, bringing items to the register, being asked about a points card and bag, and completing the purchase."
    },
    "cafe" => {
      name:        "Cafe",
      emoji:       "☕",
      description: "Order a drink and snack, ask to eat in.",
      scenario:    "A customer walks into a Japanese cafe. Guide them through: being greeted, ordering a drink and possibly a snack, choosing to eat in or take away, and paying."
    },
    "izakaya" => {
      name:        "Izakaya",
      emoji:       "🍺",
      description: "Order drinks, food, and call for the bill.",
      scenario:    "A customer enters a Japanese izakaya (pub). Guide them through: being seated, ordering drinks and food, ordering additional items, and calling for the bill at the end."
    },
    "train_station" => {
      name:        "Train Station",
      emoji:       "🚉",
      description: "Buy a ticket and ask for directions.",
      scenario:    "A traveller is at a Japanese train station. Guide them through: asking where to buy a ticket, purchasing the correct ticket, and asking which platform to use."
    },
    "hotel" => {
      name:        "Hotel",
      emoji:       "🏨",
      description: "Check in, ask about facilities.",
      scenario:    "A guest arrives at a Japanese hotel. Guide them through: checking in at the front desk, confirming reservation details, asking about breakfast and check-out time."
    }
  }.freeze

  def view_template
    div(class: "page-header") do
      h1 { "Daily Conversations" }
      link_to "← All Exercises", helpers.practice_path, class: "button button--secondary"
    end

    p(class: "exercise-instructions") do
      "Choose a scenario. The staff will speak Japanese — you respond in Japanese. The conversation continues until the scenario is complete."
    end

    div(class: "exercise-grid") do
      THEMES.each do |key, theme|
        a(href: helpers.daily_conversations_exercise_path(theme: key), class: "exercise-card") do
          div(class: "exercise-card-header") do
            h2(class: "exercise-card-title") { "#{theme[:emoji]} #{theme[:name]}" }
          end
          p(class: "exercise-card-desc") { theme[:description] }
        end
      end
    end
  end
end
