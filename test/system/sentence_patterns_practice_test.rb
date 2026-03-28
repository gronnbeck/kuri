# frozen_string_literal: true

require "application_system_test_case"

class SentencePatternsPracticeTest < ApplicationSystemTestCase
  CORRECT_RESULT = SentencePatternChecker::Result.new(
    correct: true,
    feedback: "Great job! Your sentence is correct."
  )

  INCORRECT_RESULT = SentencePatternChecker::Result.new(
    correct: false,
    feedback: "Not quite — check the particle."
  )

  # Replaces SentencePatternChecker.call for the block's duration.
  def with_checker_result(result)
    original = SentencePatternChecker.method(:call)
    SentencePatternChecker.define_singleton_method(:call) { |**| result }
    yield
  ensure
    SentencePatternChecker.define_singleton_method(:call, original)
  end

  # --- Navigation ---

  test "practice index links to sentence patterns" do
    visit practice_path
    assert_text "Sentence Patterns"
    click_link "Sentence Patterns"
    assert_current_path practice_sentence_patterns_path
  end

  test "sentence patterns reference page has Start Practice button" do
    visit practice_sentence_patterns_path
    assert_selector "a", text: "Start Practice"
  end

  test "clicking Start Practice navigates to exercise" do
    visit practice_sentence_patterns_path
    click_link "Start Practice"
    assert_current_path practice_sentence_patterns_exercise_path
  end

  # --- Exercise page ---

  test "exercise page shows a pattern, english sentence, and form" do
    visit practice_sentence_patterns_exercise_path
    assert_selector ".sp-pattern-formula"
    assert_selector ".sp-english"
    assert_selector "textarea[name='answer']"
    assert_selector "button", text: "Check"
    assert_selector "a", text: "Exit"
  end

  test "Exit link returns to sentence patterns reference page" do
    visit practice_sentence_patterns_exercise_path
    click_link "Exit"
    assert_current_path practice_sentence_patterns_path
  end

  # --- Correct answer flow ---

  test "correct answer shows success feedback and countdown" do
    with_checker_result(CORRECT_RESULT) do
      visit practice_sentence_patterns_exercise_path
      fill_in "answer", with: "私はパンを食べます。"
      click_button "Check"

      assert_selector ".sp-result--correct"
      assert_text "Correct!"
      assert_text "Great job! Your sentence is correct."
      assert_selector "#sp-countdown"
    end
  end

  test "correct answer auto-advances to next exercise after countdown" do
    with_checker_result(CORRECT_RESULT) do
      visit practice_sentence_patterns_exercise_path
      fill_in "answer", with: "私はパンを食べます。"
      click_button "Check"

      assert_selector ".sp-result--correct"
      # Countdown is 3 seconds; wait for auto-advance with buffer
      assert_current_path practice_sentence_patterns_exercise_path, wait: 5
      assert_selector ".sp-pattern-formula", wait: 5
      assert_selector "textarea[name='answer']", wait: 5
    end
  end

  # --- Incorrect answer flow ---

  test "incorrect answer shows feedback and keeps form visible" do
    with_checker_result(INCORRECT_RESULT) do
      visit practice_sentence_patterns_exercise_path
      fill_in "answer", with: "パンです。"
      click_button "Check"

      assert_selector ".sp-result--incorrect"
      assert_text "Not quite"
      assert_text "Not quite — check the particle."
      assert_selector "textarea[name='answer']"
      assert_no_selector "#sp-countdown"
    end
  end

  test "incorrect answer pre-fills textarea with previous attempt" do
    with_checker_result(INCORRECT_RESULT) do
      visit practice_sentence_patterns_exercise_path
      fill_in "answer", with: "パンです。"
      click_button "Check"

      assert_field "answer", with: "パンです。"
    end
  end

  test "user can correct answer and resubmit after incorrect" do
    call_count = 0
    original = SentencePatternChecker.method(:call)
    SentencePatternChecker.define_singleton_method(:call) do |**|
      call_count += 1
      call_count == 1 ? INCORRECT_RESULT : CORRECT_RESULT
    end

    visit practice_sentence_patterns_exercise_path
    fill_in "answer", with: "パンです。"
    click_button "Check"
    assert_selector ".sp-result--incorrect"

    fill_in "answer", with: "私はパンを食べます。"
    click_button "Check"
    assert_selector ".sp-result--correct"
    assert_text "Correct!"
  ensure
    SentencePatternChecker.define_singleton_method(:call, original)
  end
end
