# frozen_string_literal: true

require "test_helper"

class PracticeControllerTest < ActionDispatch::IntegrationTest
  # --- guided_translation ---

  test "guided_translation_exercise renders a random sentence with form" do
    TranslationSentence.create!(english: "I eat sushi.", japanese: "寿司を食べます。")
    get guided_translation_exercise_path
    assert_response :success
    assert_select ".sp-english"
    assert_select "textarea[name='answer']"
    assert_select "button[type='submit']", text: /Check/
    assert_select "a", text: /Exit/
  end

  test "check_guided_translation shows correct result" do
    sentence = TranslationSentence.create!(english: "I eat sushi.", japanese: "寿司を食べます。")
    with_checker_result(correct: true, feedback: "Perfect!") do
      post check_guided_translation_path, params: { sentence_id: sentence.id, answer: "寿司を食べます。" }
    end

    assert_response :success
    assert_select ".sp-result--correct"
    assert_select "#sp-countdown"
  end

  test "check_guided_translation shows incorrect result with correct answer revealed" do
    sentence = TranslationSentence.create!(english: "I eat sushi.", japanese: "寿司を食べます。")
    with_checker_result(correct: false, feedback: "Try again!") do
      post check_guided_translation_path, params: { sentence_id: sentence.id, answer: "wrong" }
    end

    assert_response :success
    assert_select ".sp-result--incorrect"
    assert_select ".sp-result-answer", text: /寿司を食べます。/
    assert_select "textarea[name='answer']"
  end

  test "guided_translation renders sentences from db" do
    TranslationSentence.create!(english: "I eat bread.", japanese: "パンを食べます。")
    get practice_guided_translation_path
    assert_response :success
    assert_select ".translation-en", text: /I eat bread./
  end

  test "generate_translation_sentence creates a sentence and redirects with notice" do
    sentence = TranslationSentence.new(english: "I buy coffee.", japanese: "コーヒーを買います。")
    original = TranslationSentenceGenerator.method(:call)
    TranslationSentenceGenerator.define_singleton_method(:call) { sentence }

    post generate_translation_sentence_path

    assert_redirected_to practice_guided_translation_path
    assert_match "I buy coffee.", flash[:notice]
  ensure
    TranslationSentenceGenerator.define_singleton_method(:call, original)
  end

  test "generate_translation_sentence redirects with alert on failure" do
    original = TranslationSentenceGenerator.method(:call)
    TranslationSentenceGenerator.define_singleton_method(:call) { raise "psi not found" }

    post generate_translation_sentence_path

    assert_redirected_to practice_guided_translation_path
    assert_match "psi not found", flash[:alert]
  ensure
    TranslationSentenceGenerator.define_singleton_method(:call, original)
  end

  # --- word_hint ---

  test "word_hint returns structured json from translator" do
    result = WordTranslator::Result.new(japanese: "コーヒー", furigana: "こーひー", description: "coffee (noun)")
    original = WordTranslator.method(:call)
    WordTranslator.define_singleton_method(:call) { |_| result }

    get practice_word_hint_path, params: { word: "coffee" }

    assert_response :success
    assert_equal "application/json", response.media_type
    body = response.parsed_body
    assert_equal "コーヒー", body["japanese"]
    assert_equal "こーひー", body["furigana"]
    assert_equal "coffee (noun)", body["description"]
  ensure
    WordTranslator.define_singleton_method(:call, original)
  end

  test "word_hint serves cached result from db without calling translator" do
    Word.create!(english: "water", japanese: "水", furigana: "みず", description: "water (noun)")

    get practice_word_hint_path, params: { word: "water" }

    assert_response :success
    assert_equal "水", response.parsed_body["japanese"]
    assert_equal "みず", response.parsed_body["furigana"]
  end

  test "word_hint returns 400 when word param is missing" do
    get practice_word_hint_path, params: { word: "" }
    assert_response :bad_request
  end

  test "word_hint returns 422 when translator raises" do
    original = WordTranslator.method(:call)
    WordTranslator.define_singleton_method(:call) { |_| raise "psi not found" }

    get practice_word_hint_path, params: { word: "coffee" }

    assert_response :unprocessable_entity
    assert_match "psi not found", response.parsed_body["error"]
  ensure
    WordTranslator.define_singleton_method(:call, original)
  end

  # --- sentence_transformation (GET) ---

  test "sentence_transformation renders base sentence and form" do
    get practice_sentence_transformation_path
    assert_response :success
    assert_select ".sp-pattern-formula"
    assert_select ".sp-english"
    assert_select "textarea[name='answer']"
    assert_select "input[name='sentence_index']"
    assert_select "button[type='submit']", text: /Check/
    assert_select "a", text: /All Exercises/
  end

  # --- check_sentence_transformation (POST) ---

  test "check_sentence_transformation shows correct result and countdown" do
    with_checker_result(correct: true, feedback: "Perfect!") do
      post practice_sentence_transformation_path, params: { sentence_index: 0, answer: "私はコーヒーを飲みます。" }
    end

    assert_response :success
    assert_select ".sp-result--correct"
    assert_select ".sp-result-verdict", text: /Correct/
    assert_select "#sp-countdown"
  end

  test "check_sentence_transformation shows incorrect result with correct answer and keeps form" do
    with_checker_result(correct: false, feedback: "Try again!") do
      post practice_sentence_transformation_path, params: { sentence_index: 0, answer: "wrong" }
    end

    assert_response :success
    assert_select ".sp-result--incorrect"
    assert_select ".sp-result-answer"
    assert_select "textarea[name='answer']"
    assert_select "#sp-countdown", count: 0
  end

  test "check_sentence_transformation pre-fills textarea with previous answer on incorrect" do
    with_checker_result(correct: false, feedback: "Close!") do
      post practice_sentence_transformation_path, params: { sentence_index: 0, answer: "飲みます。" }
    end

    assert_select "textarea[name='answer']", text: /飲みます。/
  end

  # --- index ---

  test "index renders exercise cards" do
    get practice_path
    assert_response :success
    assert_select ".exercise-card", 5
    assert_select ".exercise-card", text: /Sentence Patterns/
    assert_select ".exercise-card", text: /Word Guess/
  end

  # --- sentence_patterns reference page ---

  test "sentence_patterns renders reference grid and start button" do
    get practice_sentence_patterns_path
    assert_response :success
    assert_select ".pattern-card", 20
    assert_select "a[href='#{practice_sentence_patterns_exercise_path}']", text: /Start Practice/
  end

  # --- sentence_patterns_exercise (GET) ---

  test "sentence_patterns_exercise renders a pattern and english sentence" do
    get practice_sentence_patterns_exercise_path
    assert_response :success
    assert_select ".sp-pattern-formula"
    assert_select ".sp-english"
    assert_select "textarea[name='answer']"
    assert_select "input[name='pattern_index']"
    assert_select "input[name='english']"
    assert_select "button[type='submit']", text: /Check/
    assert_select "a", text: /Exit/
  end

  # --- check_sentence_pattern (POST) ---

  test "check renders correct result and countdown when answer is correct" do
    with_checker_result(correct: true, feedback: "Perfect!") do
      post check_sentence_pattern_path, params: {
        pattern_index: 6,
        english: "I eat bread.",
        answer: "私はパンを食べます。"
      }
    end

    assert_response :success
    assert_select ".sp-result--correct"
    assert_select ".sp-result-verdict", text: /Correct/
    assert_select ".sp-result-feedback", text: /Perfect!/
    assert_select "#sp-countdown"
  end

  test "check renders incorrect result and keeps form when answer is wrong" do
    with_checker_result(correct: false, feedback: "Try again!") do
      post check_sentence_pattern_path, params: {
        pattern_index: 6,
        english: "I eat bread.",
        answer: "パンです。"
      }
    end

    assert_response :success
    assert_select ".sp-result--incorrect"
    assert_select ".sp-result-verdict", text: /Not quite/
    assert_select ".sp-result-feedback", text: /Try again!/
    assert_select "textarea[name='answer']"
    assert_select "#sp-countdown", count: 0
  end

  test "check pre-fills textarea with the previous answer on incorrect" do
    with_checker_result(correct: false, feedback: "Close!") do
      post check_sentence_pattern_path, params: {
        pattern_index: 7,
        english: "I drink juice.",
        answer: "ジュースです。"
      }
    end

    assert_select "textarea[name='answer']", text: /ジュースです。/
  end

  test "check passes the correct pattern text to the checker" do
    expected_pattern = Views::Practice::SentencePatterns::PATTERNS[0][:pattern]
    received_pattern = nil

    with_checker_result(correct: true, feedback: "Good!", spy: ->(pattern:, **) { received_pattern = pattern }) do
      post check_sentence_pattern_path, params: {
        pattern_index: 0,
        english: "She is a teacher.",
        answer: "田中さんは先生です。"
      }
    end

    assert_equal expected_pattern, received_pattern
  end

  private

  # Temporarily replaces SentencePatternChecker.call for the duration of the block.
  def with_checker_result(correct:, feedback:, spy: nil)
    original = SentencePatternChecker.method(:call)
    result = SentencePatternChecker::Result.new(correct: correct, feedback: feedback)
    SentencePatternChecker.define_singleton_method(:call) do |**kwargs|
      spy&.call(**kwargs)
      result
    end
    yield
  ensure
    SentencePatternChecker.define_singleton_method(:call, original)
  end
end
