# frozen_string_literal: true

require "test_helper"

class VerbTransformationExercisesControllerTest < ActionDispatch::IntegrationTest
  STUB_RESULT = VerbTransformationExerciseGenerator::Result.new(
    verb_jp:          "食べる",
    verb_en:          "to eat",
    verb_reading:     "たべる",
    target_form:      "te_form",
    answer_jp:        "食べて",
    answer_en:        "eating / and then",
    answer_reading:   "たべて",
    difficulty_level: "n5",
    notes:            "Group 2 verb — drop る, add て"
  )

  # --- generate ---

  test "generate creates an exercise and redirects to show" do
    with_generator(STUB_RESULT) do
      assert_difference "VerbTransformationExercise.count", 1 do
        post generate_verb_transformation_exercises_path, params: { difficulty: "n5", target_form: "te_form" }
      end
    end

    exercise = VerbTransformationExercise.last
    assert_redirected_to verb_transformation_exercise_path(exercise)
    assert_equal "食べる",   exercise.verb_jp
    assert_equal "食べて",   exercise.answer_jp
    assert_equal "te_form", exercise.target_form
    assert_equal "n5",      exercise.difficulty_level
  end

  test "generate uses AI-inferred difficulty when verb is supplied" do
    result = STUB_RESULT.dup.tap { |r| r.difficulty_level = "n4" }
    with_generator(result) do
      post generate_verb_transformation_exercises_path, params: { verb: "食べる", target_form: "te_form" }
    end

    assert_equal "n4", VerbTransformationExercise.last.difficulty_level
  end

  test "generate falls back to param difficulty when result has no difficulty_level" do
    result = STUB_RESULT.dup.tap { |r| r.difficulty_level = nil }
    with_generator(result) do
      post generate_verb_transformation_exercises_path, params: { difficulty: "n3", target_form: "te_form" }
    end

    assert_equal "n3", VerbTransformationExercise.last.difficulty_level
  end

  test "generate defaults difficulty to n5 when neither verb nor difficulty given" do
    with_generator(STUB_RESULT) do
      post generate_verb_transformation_exercises_path
    end

    assert_equal "n5", VerbTransformationExercise.last.difficulty_level
  end

  test "generate handles AI returning a target form label instead of key" do
    result = STUB_RESULT.dup.tap { |r| r.target_form = "て-form" }
    with_generator(result) do
      post generate_verb_transformation_exercises_path, params: { difficulty: "n5", target_form: "te_form" }
    end

    assert_equal "te_form", VerbTransformationExercise.last.target_form
  end

  test "generate redirects with alert on generator failure" do
    with_failing_generator("psi not found") do
      assert_no_difference "VerbTransformationExercise.count" do
        post generate_verb_transformation_exercises_path, params: { difficulty: "n5" }
      end
    end

    assert_redirected_to new_verb_transformation_exercise_path
    assert_match "psi not found", flash[:alert]
  end

  # --- index ---

  test "index lists active exercises" do
    VerbTransformationExercise.create!(verb_jp: "行く", answer_jp: "行って", target_form: "te_form", difficulty_level: "n5")
    VerbTransformationExercise.create!(verb_jp: "来る", answer_jp: "来て",   target_form: "te_form", difficulty_level: "n4", archived: true)

    get verb_transformation_exercises_path

    assert_response :success
    assert_select "*", text: /行く/
    assert_select "*", text: /来る/, count: 0
  end

  test "index lists archived exercises when param is set" do
    VerbTransformationExercise.create!(verb_jp: "行く", answer_jp: "行って", target_form: "te_form", difficulty_level: "n5")
    VerbTransformationExercise.create!(verb_jp: "来る", answer_jp: "来て",   target_form: "te_form", difficulty_level: "n4", archived: true)

    get verb_transformation_exercises_path(archived: 1)

    assert_response :success
    assert_select "*", text: /来る/
    assert_select "*", text: /行く/, count: 0
  end

  # --- show ---

  test "show renders the exercise card" do
    exercise = VerbTransformationExercise.create!(
      verb_jp: "食べる", verb_en: "to eat", verb_reading: "たべる",
      target_form: "te_form",
      answer_jp: "食べて", answer_en: "eating", answer_reading: "たべて",
      difficulty_level: "n5"
    )

    get verb_transformation_exercise_path(exercise)

    assert_response :success
    assert_select "*", text: /食べる/
    assert_select "*", text: /食べて/
    assert_select "*", text: /て-form/
  end

  # --- archive ---

  test "archive toggles archived flag and redirects to index" do
    exercise = VerbTransformationExercise.create!(verb_jp: "食べる", answer_jp: "食べて", target_form: "te_form", difficulty_level: "n5")

    post archive_verb_transformation_exercise_path(exercise)

    assert_redirected_to verb_transformation_exercises_path
    assert exercise.reload.archived?
  end

  private

  def with_generator(result)
    original = VerbTransformationExerciseGenerator.method(:call)
    VerbTransformationExerciseGenerator.define_singleton_method(:call) { |**| result }
    yield
  ensure
    VerbTransformationExerciseGenerator.define_singleton_method(:call, original)
  end

  def with_failing_generator(message)
    original = VerbTransformationExerciseGenerator.method(:call)
    VerbTransformationExerciseGenerator.define_singleton_method(:call) { |**| raise message }
    yield
  ensure
    VerbTransformationExerciseGenerator.define_singleton_method(:call, original)
  end
end
