# frozen_string_literal: true

require "test_helper"

class ConversationExercisesControllerTest < ActionDispatch::IntegrationTest
  # --- generate_audio ---

  test "generate_audio for request picks a random actor and attaches audio" do
    actor    = Actor.create!(voice_id: "voice-abc")
    exercise = build_exercise

    with_tts("FAKEMP3") do
      post generate_audio_conversation_exercise_path(exercise, kind: "request")
    end

    ca = exercise.conversation_audios.find_by!(kind: "request")
    assert ca.audio.attached?
    assert_equal actor.id, ca.actor_id
    assert_redirected_to conversation_exercise_path(exercise)
  end

  test "generate_audio for response picks a different actor than request when two exist" do
    a1 = Actor.create!(voice_id: "voice-1")
    a2 = Actor.create!(voice_id: "voice-2")
    exercise = build_exercise

    # Pre-create request audio attributed to a1
    exercise.conversation_audios.create!(kind: "request", actor: a1)

    with_tts("FAKEMP3") do
      post generate_audio_conversation_exercise_path(exercise, kind: "response")
    end

    response_ca = exercise.conversation_audios.find_by!(kind: "response")
    assert_equal a2.id, response_ca.actor_id
  end

  test "generate_audio for response uses the only actor when just one exists" do
    actor    = Actor.create!(voice_id: "voice-only")
    exercise = build_exercise
    exercise.conversation_audios.create!(kind: "request", actor: actor)

    with_tts("FAKEMP3") do
      post generate_audio_conversation_exercise_path(exercise, kind: "response")
    end

    response_ca = exercise.conversation_audios.find_by!(kind: "response")
    assert_equal actor.id, response_ca.actor_id
  end

  test "generate_audio for request picks a different actor than existing response" do
    a1 = Actor.create!(voice_id: "voice-1")
    a2 = Actor.create!(voice_id: "voice-2")
    exercise = build_exercise
    exercise.conversation_audios.create!(kind: "response", actor: a2)

    with_tts("FAKEMP3") do
      post generate_audio_conversation_exercise_path(exercise, kind: "request")
    end

    request_ca = exercise.conversation_audios.find_by!(kind: "request")
    assert_equal a1.id, request_ca.actor_id
  end

  test "generate_audio redirects with alert when no actors exist" do
    exercise = build_exercise

    post generate_audio_conversation_exercise_path(exercise, kind: "request")

    assert_redirected_to conversation_exercise_path(exercise)
    assert_match "actor", flash[:alert]
  end

  private

  def build_exercise
    ConversationExercise.create!(
      request_jp:  "これは何ですか",
      request_en:  "What is this?",
      response_jp: "これは本です",
      response_en: "This is a book.",
      difficulty_level: "n5"
    )
  end

  def with_tts(data)
    original = ElevenLabsTts.method(:call)
    ElevenLabsTts.define_singleton_method(:call) { |*| data }
    yield
  ensure
    ElevenLabsTts.define_singleton_method(:call, original)
  end
end
