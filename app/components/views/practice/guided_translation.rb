# frozen_string_literal: true

class Views::Practice::GuidedTranslation < ApplicationView
  def initialize(sentences:)
    @sentences = sentences
  end

  def view_template
    div(class: "page-header") do
      h1 { "Guided Translation" }
      div(class: "header-actions") do
        button_to "Generate new", helpers.generate_translation_sentence_path, class: "button button--secondary"
        link_to "Practice", helpers.guided_translation_exercise_path, class: "button"
        link_to "← All Exercises", helpers.practice_path, class: "button button--secondary"
      end
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        h2 { "Translate into Japanese" }
        p(class: "exercise-instructions") { "Translate each sentence. Keep sentences short and use beginner grammar patterns." }

        if @sentences.empty?
          p { "No sentences yet." }
        else
          ol(class: "translation-list") do
            @sentences.each_with_index do |s, i|
              li(class: "translation-item") do
                div(class: "translation-en") { s.english }
                div(class: "translation-input-row") do
                  input(
                    type: "text",
                    class: "translation-input",
                    placeholder: "Japanese translation...",
                    data: { answer: s.japanese, index: i }
                  )
                  button(type: "button", class: "button button--secondary reveal-btn", data: { index: i }) { "Show" }
                end
                div(class: "translation-answer hidden", id: "answer-#{i}") { s.japanese }
              end
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
