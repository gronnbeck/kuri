# frozen_string_literal: true

class Views::Practice::Index < ApplicationView
  EXERCISES = [
    {
      title: "Sentence Patterns",
      description: "Reference and practice 20 essential beginner Japanese sentence patterns.",
      path_helper: :practice_sentence_patterns_path,
      difficulty: :easy
    },
    {
      title: "Guided Translation",
      description: "Translate 10 short English sentences into Japanese using beginner grammar.",
      path_helper: :practice_guided_translation_path,
      difficulty: :easy
    },
    {
      title: "Micro Sentences",
      description: "Write 5 personal sentences about your day using simple Japanese patterns.",
      path_helper: :practice_micro_sentences_path,
      difficulty: :medium
    },
    {
      title: "Sentence Transformation",
      description: "Take a base sentence and practice transforming it by subject, tense, polarity, and question form.",
      path_helper: :practice_sentence_transformation_path,
      difficulty: :medium
    },
    {
      title: "Daily Conversations",
      description: "Practice back-and-forth Japanese conversations in real settings like restaurants, cafes, and convenience stores.",
      path_helper: :practice_daily_conversations_path,
      difficulty: :medium
    },
    {
      title: "Word Guess",
      description: "Describe a word from your deck without saying it. Test your vocabulary recall.",
      path_helper: :practice_word_guess_path,
      difficulty: :hard
    }
  ].freeze

  DIFFICULTY_LABELS = {
    easy: "Easy",
    medium: "Medium",
    hard: "Hard"
  }.freeze

  def view_template
    div(class: "page-header") do
      h1 { "Practice" }
    end

    div(class: "exercise-grid") do
      EXERCISES.each do |ex|
        a(href: helpers.public_send(ex[:path_helper]), class: "exercise-card") do
          div(class: "exercise-card-header") do
            h2(class: "exercise-card-title") { ex[:title] }
            span(class: "difficulty-badge difficulty-badge--#{ex[:difficulty]}") do
              DIFFICULTY_LABELS[ex[:difficulty]]
            end
          end
          p(class: "exercise-card-desc") { ex[:description] }
        end
      end
    end
  end
end
