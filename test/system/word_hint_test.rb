# frozen_string_literal: true

require "application_system_test_case"

class WordHintTest < ApplicationSystemTestCase
  def with_translator(result)
    original = WordTranslator.method(:call)
    WordTranslator.define_singleton_method(:call) { |_| result }
    yield
  ensure
    WordTranslator.define_singleton_method(:call, original)
  end

  test "clicking a word shows a tooltip with the japanese translation" do
    with_translator(WordTranslator::Result.new(japanese: "コーヒー", furigana: "こーひー", description: "coffee")) do
      visit practice_sentence_patterns_exercise_path

      word = find(".sp-word", match: :first)
      word.click

      assert_selector ".word-hint-tooltip", text: "コーヒー"
    end
  end

  test "tooltip is not visible before clicking" do
    visit practice_sentence_patterns_exercise_path
    assert_no_selector ".word-hint-tooltip"
  end

  test "clicking elsewhere dismisses the tooltip" do
    with_translator(WordTranslator::Result.new(japanese: "水", furigana: "みず", description: "water")) do
      visit practice_sentence_patterns_exercise_path

      find(".sp-word", match: :first).click
      assert_selector ".word-hint-tooltip"

      find("h1").click
      assert_no_selector ".word-hint-tooltip"
    end
  end

  test "clicking the same word again dismisses the tooltip" do
    with_translator(WordTranslator::Result.new(japanese: "水", furigana: "みず", description: "water")) do
      visit practice_sentence_patterns_exercise_path

      word = find(".sp-word", match: :first)
      word.click
      assert_selector ".word-hint-tooltip"

      word.click
      assert_no_selector ".word-hint-tooltip"
    end
  end

  test "shows loading indicator while fetching" do
    # Block the translator so we can observe the loading state
    blocker = Mutex.new
    blocker.lock

    original = WordTranslator.method(:call)
    WordTranslator.define_singleton_method(:call) do |_|
      blocker.lock   # waits until test releases it
      WordTranslator::Result.new(japanese: "犬", furigana: "いぬ", description: "dog")
    end

    visit practice_sentence_patterns_exercise_path
    find(".sp-word", match: :first).click
    assert_selector ".word-hint-tooltip", text: "···"

    blocker.unlock
    assert_selector ".word-hint-tooltip", text: "犬", wait: 3
  ensure
    blocker.unlock rescue nil
    WordTranslator.define_singleton_method(:call, original)
  end
end
