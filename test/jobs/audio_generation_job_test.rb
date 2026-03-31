# frozen_string_literal: true

require "test_helper"

class AudioGenerationJobTest < ActiveJob::TestCase
  def setup
    @actor1 = Actor.create!(name: "Aiko", voice_id: "voice_aiko")
    @actor2 = Actor.create!(name: "Kenji", voice_id: "voice_kenji")

    # Stub ElevenLabsTts so no real HTTP calls are made
    ElevenLabsTts.define_singleton_method(:call) { |_text, **_opts| "FAKEAUDIO" }
  end

  def teardown
    original = ElevenLabsTts.method(:call)
    # nothing to restore — define_singleton_method overrides only the singleton
  end

  # ── ConversationExercise ─────────────────────────────────────────────────────

  test "generates request and response audio for a conversation exercise" do
    exercise = ConversationExercise.create!(
      request_jp: "いらっしゃいませ", request_en: "Welcome",
      request_reading: "いらっしゃいませ",
      response_jp: "ありがとうございます", response_en: "Thank you",
      response_reading: "ありがとうございます",
      difficulty_level: "n5"
    )

    AudioGenerationJob.perform_now("ConversationExercise", exercise.id)

    exercise.reload
    assert exercise.request_audio&.audio&.attached?, "request audio should be attached"
    assert exercise.response_audio&.audio&.attached?, "response audio should be attached"
  end

  test "skips silently when no actors exist for conversation exercise" do
    Actor.delete_all
    exercise = ConversationExercise.create!(
      request_jp: "こんにちは", request_en: "Hello",
      response_jp: "こんにちは", response_en: "Hello",
      difficulty_level: "n5"
    )

    assert_nothing_raised { AudioGenerationJob.perform_now("ConversationExercise", exercise.id) }
    assert_nil exercise.request_audio
  end

  # ── VerbTransformationExercise ───────────────────────────────────────────────

  test "generates verb and answer audio for a verb exercise" do
    exercise = VerbTransformationExercise.create!(
      verb_jp: "食べる", verb_en: "to eat", verb_reading: "たべる",
      target_form: "te_form",
      answer_jp: "食べて", answer_en: "eating", answer_reading: "たべて",
      difficulty_level: "n5"
    )

    AudioGenerationJob.perform_now("VerbTransformationExercise", exercise.id)

    exercise.reload
    assert exercise.verb_audio&.audio&.attached?,   "verb audio should be attached"
    assert exercise.answer_audio&.audio&.attached?, "answer audio should be attached"
  end

  test "skips silently when no actors exist for verb exercise" do
    Actor.delete_all
    exercise = VerbTransformationExercise.create!(
      verb_jp: "食べる", verb_en: "to eat",
      target_form: "te_form",
      answer_jp: "食べて", answer_en: "eating",
      difficulty_level: "n5"
    )

    assert_nothing_raised { AudioGenerationJob.perform_now("VerbTransformationExercise", exercise.id) }
    assert_nil exercise.verb_audio
  end

  # ── BatchGenerationJob enqueues AudioGenerationJob ───────────────────────────

  test "batch generation enqueues audio generation job for each completed card" do
    batch = Batch.create!(kind: :conversation, total: 2, difficulty: "n5")
    2.times { batch.batch_items.create! }

    result = ConversationExerciseGenerator::Result.new(
      request_jp: "テスト", request_en: "Test", request_reading: "てすと",
      response_jp: "はい", response_en: "Yes", response_reading: "はい",
      notes: nil
    )

    original = ConversationExerciseGenerator.method(:call)
    ConversationExerciseGenerator.define_singleton_method(:call) { |**| result }

    assert_enqueued_with(job: AudioGenerationJob) do
      BatchGenerationJob.perform_now(batch.id)
    end
  ensure
    ConversationExerciseGenerator.define_singleton_method(:call, original)
  end
end
