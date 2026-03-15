# frozen_string_literal: true

class Views::Practice::GuidedTranslation < ApplicationView
  SENTENCES = [
    { en: "I drink water.", jp: "私は水を飲みます。" },
    { en: "I eat rice.", jp: "私はご飯を食べます。" },
    { en: "I study Japanese.", jp: "私は日本語を勉強します。" },
    { en: "I go to school.", jp: "私は学校に行きます。" },
    { en: "My friend reads books.", jp: "友達は本を読みます。" },
    { en: "I drink coffee at home.", jp: "私は家でコーヒーを飲みます。" },
    { en: "I watch TV tonight.", jp: "今夜テレビを見ます。" },
    { en: "I eat sushi.", jp: "私は寿司を食べます。" },
    { en: "I study at home.", jp: "私は家で勉強します。" },
    { en: "I read a book.", jp: "私は本を読みます。" }
  ].freeze

  def view_template
    div(class: "page-header") do
      h1 { "Guided Translation" }
      link_to "← All Exercises", helpers.practice_path, class: "button button--secondary"
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        h2 { "Translate into Japanese" }
        p(class: "exercise-instructions") { "Translate each sentence. Keep sentences short and use beginner grammar patterns." }

        ol(class: "translation-list") do
          SENTENCES.each_with_index do |s, i|
            li(class: "translation-item") do
              div(class: "translation-en") { s[:en] }
              div(class: "translation-input-row") do
                input(
                  type: "text",
                  class: "translation-input",
                  placeholder: "Japanese translation...",
                  data: { answer: s[:jp], index: i }
                )
                button(type: "button", class: "button button--secondary reveal-btn", data: { index: i }) { "Show" }
              end
              div(class: "translation-answer hidden", id: "answer-#{i}") { s[:jp] }
            end
          end
        end
      end
    end

    script do
      raw Phlex::SGML::SafeValue.new(<<~JS)
        document.querySelectorAll('.reveal-btn').forEach(btn => {
          btn.addEventListener('click', () => {
            const idx = btn.dataset.index;
            const answer = document.getElementById('answer-' + idx);
            answer.classList.toggle('hidden');
            btn.textContent = answer.classList.contains('hidden') ? 'Show' : 'Hide';
          });
        });
      JS
    end
  end
end
