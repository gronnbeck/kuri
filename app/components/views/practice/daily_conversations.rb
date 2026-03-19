# frozen_string_literal: true

class Views::Practice::DailyConversations < ApplicationView
  THEMES = {
    "restaurant" => {
      name:        "Restaurant",
      emoji:       "🍱",
      description: "Be seated, order food, ask for the bill.",
      scenario:    "A customer walks into a Japanese restaurant. Guide them through: being greeted and seated, ordering food and drinks, receiving the meal, and paying the bill.",
      phrases:     [
        { jp: "すみません",           en: "Excuse me" },
        { jp: "〜をください",          en: "Please give me ~" },
        { jp: "〜をひとつお願いします", en: "One ~ please" },
        { jp: "おすすめは何ですか？",  en: "What do you recommend?" },
        { jp: "お会計をお願いします",  en: "Check please" },
        { jp: "おいしかったです",      en: "It was delicious" },
        { jp: "ごちそうさまでした",    en: "Thank you for the meal" },
        { jp: "予約しています",        en: "I have a reservation" },
        { jp: "一人です",             en: "Just one person" },
        { jp: "二人です",             en: "Two people" }
      ]
    },
    "konbini" => {
      name:        "Convenience Store",
      emoji:       "🏪",
      description: "Pay at the register, get a bag, use a points card.",
      scenario:    "A customer is shopping at a Japanese convenience store. Guide them through: being greeted, bringing items to the register, being asked about a points card and bag, and completing the purchase.",
      phrases:     [
        { jp: "ポイントカードはありますか？", en: "Do you have a points card?" },
        { jp: "ポイントカードはないです",     en: "I don't have a points card" },
        { jp: "袋をください",               en: "Please give me a bag" },
        { jp: "袋は大丈夫です",             en: "No bag needed, thank you" },
        { jp: "温めてください",             en: "Please heat this up" },
        { jp: "クレジットカードで払います",  en: "I'll pay by credit card" },
        { jp: "現金で払います",             en: "I'll pay in cash" },
        { jp: "レシートをください",          en: "Receipt please" }
      ]
    },
    "cafe" => {
      name:        "Cafe",
      emoji:       "☕",
      description: "Order a drink and snack, ask to eat in.",
      scenario:    "A customer walks into a Japanese cafe. Guide them through: being greeted, ordering a drink and possibly a snack, choosing to eat in or take away, and paying.",
      phrases:     [
        { jp: "コーヒーをひとつください",   en: "One coffee please" },
        { jp: "〜をお願いします",           en: "~ please" },
        { jp: "ホットにしてください",       en: "Hot please" },
        { jp: "アイスにしてください",       en: "Iced please" },
        { jp: "店内で食べます",            en: "For here" },
        { jp: "テイクアウトします",         en: "To go" },
        { jp: "おすすめのケーキはありますか？", en: "Do you have a recommended cake?" },
        { jp: "〜のサイズはありますか？",   en: "Do you have ~ size?" }
      ]
    },
    "izakaya" => {
      name:        "Izakaya",
      emoji:       "🍺",
      description: "Order drinks, food, and call for the bill.",
      scenario:    "A customer enters a Japanese izakaya (pub). Guide them through: being seated, ordering drinks and food, ordering additional items, and calling for the bill at the end.",
      phrases:     [
        { jp: "生ビールをください",        en: "Draft beer please" },
        { jp: "おすすめは何ですか？",      en: "What do you recommend?" },
        { jp: "〜をふたつください",        en: "Two ~ please" },
        { jp: "もう一杯ください",          en: "One more please" },
        { jp: "同じものをください",        en: "Same again please" },
        { jp: "お会計をお願いします",      en: "Check please" },
        { jp: "別々でお願いします",        en: "Separate bills please" },
        { jp: "一緒でお願いします",        en: "Together please" },
        { jp: "からい",                   en: "Spicy" },
        { jp: "アレルギーがあります",      en: "I have an allergy" }
      ]
    },
    "train_station" => {
      name:        "Train Station",
      emoji:       "🚉",
      description: "Buy a ticket and ask for directions.",
      scenario:    "A traveller is at a Japanese train station. Guide them through: asking where to buy a ticket, purchasing the correct ticket, and asking which platform to use.",
      phrases:     [
        { jp: "〜まで一枚ください",        en: "One ticket to ~ please" },
        { jp: "〜まで大人一枚",           en: "One adult to ~" },
        { jp: "自由席でいいです",          en: "Non-reserved seat is fine" },
        { jp: "何番線ですか？",           en: "Which platform?" },
        { jp: "〜行きはどこですか？",      en: "Where is the train to ~?" },
        { jp: "次の電車は何時ですか？",    en: "When is the next train?" },
        { jp: "乗り換えはありますか？",    en: "Do I need to transfer?" },
        { jp: "ICカードで払います",       en: "I'll pay with IC card" }
      ]
    },
    "hotel" => {
      name:        "Hotel",
      emoji:       "🏨",
      description: "Check in, ask about facilities.",
      scenario:    "A guest arrives at a Japanese hotel. Guide them through: checking in at the front desk, confirming reservation details, asking about breakfast and check-out time.",
      phrases:     [
        { jp: "チェックインをお願いします",    en: "I'd like to check in" },
        { jp: "予約しています",               en: "I have a reservation" },
        { jp: "〜という名前で予約しています", en: "I have a reservation under the name ~" },
        { jp: "朝食はありますか？",           en: "Is breakfast included?" },
        { jp: "チェックアウトは何時ですか？", en: "What time is check-out?" },
        { jp: "Wi-Fiはありますか？",          en: "Is there Wi-Fi?" },
        { jp: "部屋の鍵をください",           en: "Room key please" },
        { jp: "荷物を預けてもいいですか？",   en: "Can I leave my luggage here?" }
      ]
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
