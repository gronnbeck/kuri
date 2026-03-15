# frozen_string_literal: true

class Views::Practice::SentencePatterns < ApplicationView
  PATTERNS = [
    {
      pattern: "X は Y です",
      example: "これは本です。",
      en: "This is a book.",
      practice: [ "She is a teacher.", "This is water.", "I am Japanese." ]
    },
    {
      pattern: "X は Y じゃないです",
      example: "これは本じゃないです。",
      en: "This is not a book.",
      practice: [ "This is not sushi.", "I am not a student.", "He is not a doctor." ]
    },
    {
      pattern: "X は Y でした",
      example: "昨日は月曜日でした。",
      en: "Yesterday was Monday.",
      practice: [ "Yesterday was Sunday.", "She was a student.", "That was delicious." ]
    },
    {
      pattern: "X は Y じゃなかったです",
      example: "昨日は雨じゃなかったです。",
      en: "Yesterday was not rainy.",
      practice: [ "Today was not hot.", "It was not expensive.", "That was not my bag." ]
    },
    {
      pattern: "X があります",
      example: "テーブルの上に本があります。",
      en: "There is a book on the table.",
      practice: [ "There is a cat.", "There is coffee.", "There is a pen on the desk." ]
    },
    {
      pattern: "X がいます",
      example: "公園に犬がいます。",
      en: "There is a dog in the park.",
      practice: [ "There is a bird.", "There is a student.", "There is a cat in the garden." ]
    },
    {
      pattern: "X を食べます",
      example: "私はりんごを食べます。",
      en: "I eat an apple.",
      practice: [ "I eat bread.", "She eats ramen.", "I eat cake." ]
    },
    {
      pattern: "X を飲みます",
      example: "私はお茶を飲みます。",
      en: "I drink tea.",
      practice: [ "I drink juice.", "He drinks water.", "I drink milk." ]
    },
    {
      pattern: "X を見ます",
      example: "私はテレビを見ます。",
      en: "I watch TV.",
      practice: [ "I watch movies.", "She watches anime.", "I watch the news." ]
    },
    {
      pattern: "X を読みます",
      example: "私は本を読みます。",
      en: "I read a book.",
      practice: [ "I read manga.", "She reads a magazine.", "I read the newspaper." ]
    },
    {
      pattern: "X をします",
      example: "私は運動をします。",
      en: "I exercise.",
      practice: [ "I do homework.", "She does yoga.", "I do cooking." ]
    },
    {
      pattern: "X に行きます",
      example: "私は学校に行きます。",
      en: "I go to school.",
      practice: [ "I go to the store.", "She goes to work.", "I go to Japan." ]
    },
    {
      pattern: "X で勉強します",
      example: "私は図書館で勉強します。",
      en: "I study at the library.",
      practice: [ "I study at school.", "She studies at a cafe.", "I study at home." ]
    },
    {
      pattern: "X を買います",
      example: "私はパンを買います。",
      en: "I buy bread.",
      practice: [ "I buy vegetables.", "She buys clothes.", "I buy coffee." ]
    },
    {
      pattern: "X を作ります",
      example: "私は料理を作ります。",
      en: "I make food.",
      practice: [ "I make dinner.", "She makes coffee.", "I make a cake." ]
    },
    {
      pattern: "X を聞きます",
      example: "私は音楽を聞きます。",
      en: "I listen to music.",
      practice: [ "I listen to a song.", "She listens to the radio.", "I listen to podcasts." ]
    },
    {
      pattern: "X を使います",
      example: "私はパソコンを使います。",
      en: "I use a computer.",
      practice: [ "I use a phone.", "She uses chopsticks.", "I use this pen." ]
    },
    {
      pattern: "X が好きです",
      example: "私はコーヒーが好きです。",
      en: "I like coffee.",
      practice: [ "I like dogs.", "She likes music.", "I like Japan." ]
    },
    {
      pattern: "X が分かります",
      example: "私は日本語が分かります。",
      en: "I understand Japanese.",
      practice: [ "I understand English.", "She understands the question.", "I understand this word." ]
    },
    {
      pattern: "X を勉強します",
      example: "私は日本語を勉強します。",
      en: "I study Japanese.",
      practice: [ "I study Chinese.", "She studies English.", "I study Korean." ]
    }
  ].freeze

  def view_template
    div(class: "page-header") do
      h1 { "Sentence Patterns" }
      div(class: "header-actions") do
        link_to "← All Exercises", helpers.practice_path, class: "button button--secondary"
        link_to "Start Practice", helpers.practice_sentence_patterns_exercise_path, class: "button"
      end
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        h2 { "20 Essential Beginner Patterns" }
        p(class: "exercise-instructions") { "Study each pattern, read the example aloud, then try writing your own sentence using the same structure." }

        div(class: "patterns-grid") do
          PATTERNS.each_with_index do |p, i|
            div(class: "pattern-card") do
              div(class: "pattern-number") { (i + 1).to_s }
              div(class: "pattern-body") do
                div(class: "pattern-formula") { p[:pattern] }
                div(class: "pattern-example jp") { p[:example] }
                div(class: "pattern-meaning en") { p[:en] }
              end
            end
          end
        end
      end
    end
  end
end
