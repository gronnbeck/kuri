# frozen_string_literal: true

class AudioGenerationJob < ApplicationJob
  queue_as :default

  # Generates audio for all sides of an exercise.
  #
  # exercise_type - "ConversationExercise" or "VerbTransformationExercise"
  # exercise_id   - the record id
  #
  # Skips silently when no actors are configured.
  def perform(exercise_type, exercise_id)
    exercise = exercise_type.constantize.find(exercise_id)

    case exercise
    when ConversationExercise  then generate_conversation_audio(exercise)
    when VerbTransformationExercise then generate_verb_audio(exercise)
    end
  end

  private

  def generate_conversation_audio(exercise)
    request_actor = Actor.pick_random
    return unless request_actor

    response_actor = Actor.pick_random(exclude_id: request_actor.id)
    return unless response_actor

    generate_side(exercise.conversation_audios, :request,
                  exercise.request_reading.presence || exercise.request_jp,
                  "conv_#{exercise.id}_request.mp3",
                  request_actor)

    generate_side(exercise.conversation_audios, :response,
                  exercise.response_reading.presence || exercise.response_jp,
                  "conv_#{exercise.id}_response.mp3",
                  response_actor)
  end

  def generate_verb_audio(exercise)
    actor = Actor.pick_random
    return unless actor

    generate_side(exercise.verb_audios, :verb,
                  exercise.verb_reading.presence || exercise.verb_jp,
                  "verb_#{exercise.id}_verb.mp3",
                  actor)

    generate_side(exercise.verb_audios, :answer,
                  exercise.answer_reading.presence || exercise.answer_jp,
                  "verb_#{exercise.id}_answer.mp3",
                  actor)
  end

  def generate_side(audios_scope, kind, text, filename, actor)
    record = audios_scope.find_or_initialize_by(kind: kind)
    record.actor = actor
    record.save! unless record.persisted?

    audio_data = ElevenLabsTts.call(text, voice_id: actor.voice_id)
    record.audio.attach(
      io:           StringIO.new(audio_data),
      filename:     filename,
      content_type: "audio/mpeg"
    )
    record.update_columns(actor_id: actor.id)
  end
end
