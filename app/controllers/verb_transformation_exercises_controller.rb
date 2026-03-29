# frozen_string_literal: true

class VerbTransformationExercisesController < ApplicationController
  before_action :set_exercise, only: [ :show, :edit, :update, :destroy, :add_to_anki,
                                       :generate_audio, :regenerate_audio, :confirm_audio, :discard_pending_audio,
                                       :archive, :improve, :generate_readings ]

  def index
    scope = params[:archived] == "1" ? VerbTransformationExercise.where(archived: true) : VerbTransformationExercise.where(archived: false)
    @exercises = scope.order(created_at: :desc)
    render Views::VerbTransformationExercises::Index.new(exercises: @exercises, show_archived: params[:archived] == "1")
  end

  def new
    render Views::VerbTransformationExercises::New.new(exercise: VerbTransformationExercise.new)
  end

  def generate
    difficulty  = params[:difficulty].presence || "n5"
    target_form = params[:target_form].presence
    verb        = params[:verb].presence
    prompt      = params[:prompt].presence

    result = VerbTransformationExerciseGenerator.call(
      difficulty:  difficulty,
      target_form: target_form,
      verb:        verb,
      prompt:      prompt
    )

    @exercise = VerbTransformationExercise.create!(
      verb_jp:          result.verb_jp,
      verb_en:          result.verb_en,
      verb_reading:     result.verb_reading,
      target_form:      result.target_form,
      answer_jp:        result.answer_jp,
      answer_en:        result.answer_en,
      answer_reading:   result.answer_reading,
      notes:            result.notes,
      difficulty_level: result.difficulty_level.presence || difficulty
    )
    redirect_to verb_transformation_exercise_path(@exercise)
  rescue => e
    redirect_to new_verb_transformation_exercise_path, alert: "Generation failed: #{e.message}"
  end

  def show
    setting = AnkiVerbSetting.current
    anki_configured = setting.persisted? && setting.deck_name.present? && setting.note_type.present?
    render Views::VerbTransformationExercises::Show.new(exercise: @exercise, anki_configured: anki_configured)
  end

  def edit
    render Views::VerbTransformationExercises::Edit.new(exercise: @exercise)
  end

  def update
    if @exercise.update(exercise_params)
      redirect_to verb_transformation_exercise_path(@exercise), notice: "Exercise updated."
    else
      render Views::VerbTransformationExercises::Edit.new(exercise: @exercise), status: :unprocessable_entity
    end
  end

  def destroy
    @exercise.destroy
    redirect_to verb_transformation_exercises_path, notice: "Exercise deleted."
  end

  def generate_audio
    kind = params[:kind].to_s

    # For verb exercises the same actor should voice both sides.
    other_kind  = kind == "verb" ? "answer" : "verb"
    other_audio = @exercise.verb_audios.find_by(kind: other_kind)
    actor = other_audio&.actor || Actor.pick_random

    unless actor
      redirect_to verb_transformation_exercise_path(@exercise), alert: "Add an actor in Settings → Listen → Actors first."
      return
    end

    text = if kind == "verb"
      @exercise.verb_reading.presence || @exercise.verb_jp
    else
      @exercise.answer_reading.presence || @exercise.answer_jp
    end
    va   = @exercise.verb_audios.find_or_initialize_by(kind: kind)
    va.actor = actor
    va.save! unless va.persisted?

    audio_data = ElevenLabsTts.call(text, voice_id: actor.voice_id)
    va.audio.attach(
      io:           StringIO.new(audio_data),
      filename:     "verb_#{@exercise.id}_#{kind}.mp3",
      content_type: "audio/mpeg"
    )
    va.update_columns(actor_id: actor.id)
    redirect_to verb_transformation_exercise_path(@exercise), notice: "#{kind.capitalize} audio generated."
  rescue => e
    redirect_to verb_transformation_exercise_path(@exercise), alert: "Audio generation failed: #{e.message}"
  end

  def regenerate_audio
    kind = params[:kind].to_s
    va   = @exercise.verb_audios.find_by!(kind: kind)

    other_kind  = kind == "verb" ? "answer" : "verb"
    other_audio = @exercise.verb_audios.find_by(kind: other_kind)
    actor = other_audio&.actor || Actor.pick_random

    unless actor
      redirect_to verb_transformation_exercise_path(@exercise), alert: "Add an actor in Settings → Listen → Actors first."
      return
    end

    text = kind == "verb" \
      ? (@exercise.verb_reading.presence || @exercise.verb_jp)
      : (@exercise.answer_reading.presence || @exercise.answer_jp)

    audio_data = ElevenLabsTts.call(text, voice_id: actor.voice_id)
    va.pending_audio.attach(
      io:           StringIO.new(audio_data),
      filename:     "verb_#{@exercise.id}_#{kind}_pending.mp3",
      content_type: "audio/mpeg"
    )
    redirect_to verb_transformation_exercise_path(@exercise), notice: "New #{kind} audio generated — review and confirm below."
  rescue => e
    redirect_to verb_transformation_exercise_path(@exercise), alert: "Regeneration failed: #{e.message}"
  end

  def confirm_audio
    kind = params[:kind].to_s
    va   = @exercise.verb_audios.find_by!(kind: kind)
    raise "No pending audio to confirm." unless va.pending_audio.attached?

    va.audio.attach(va.pending_audio.blob)
    va.pending_audio.purge
    redirect_to verb_transformation_exercise_path(@exercise), notice: "#{kind.capitalize} audio replaced."
  rescue => e
    redirect_to verb_transformation_exercise_path(@exercise), alert: "Failed: #{e.message}"
  end

  def discard_pending_audio
    kind = params[:kind].to_s
    va   = @exercise.verb_audios.find_by!(kind: kind)
    va.pending_audio.purge
    redirect_to verb_transformation_exercise_path(@exercise), notice: "New #{kind} audio discarded."
  end

  def archive
    @exercise.update!(archived: !@exercise.archived)
    label = @exercise.archived? ? "archived" : "restored"
    redirect_to verb_transformation_exercises_path, notice: "Exercise #{label}."
  end

  def improve
    feedbacks = @exercise.verb_transformation_feedbacks.order(:created_at)
    if feedbacks.empty?
      redirect_to verb_transformation_exercise_path(@exercise), alert: "Add at least one feedback note before improving."
      return
    end

    result = VerbTransformationExerciseGenerator.improve(exercise: @exercise, feedbacks: feedbacks)
    @exercise.update!(
      verb_jp:        result.verb_jp,
      verb_en:        result.verb_en,
      verb_reading:   result.verb_reading,
      target_form:    result.target_form,
      answer_jp:      result.answer_jp,
      answer_en:      result.answer_en,
      answer_reading: result.answer_reading,
      notes:          result.notes,
      anki_status:    :not_added
    )
    redirect_to verb_transformation_exercise_path(@exercise), notice: "Exercise improved."
  rescue => e
    redirect_to verb_transformation_exercise_path(@exercise), alert: "Improvement failed: #{e.message}"
  end

  def generate_readings
    result = VerbTransformationExerciseGenerator.readings_for(exercise: @exercise)
    @exercise.update!(verb_reading: result[:verb_reading], answer_reading: result[:answer_reading])
    redirect_to verb_transformation_exercise_path(@exercise), notice: "Readings generated."
  rescue => e
    redirect_to verb_transformation_exercise_path(@exercise), alert: "Reading generation failed: #{e.message}"
  end

  def add_to_anki
    setting = AnkiVerbSetting.current
    unless setting.persisted? && setting.deck_name.present? && setting.note_type.present?
      redirect_to verb_transformation_exercise_path(@exercise), alert: "Configure Anki settings first."
      return
    end

    re_add = @exercise.added?
    exporter = AnkiConnect::VerbExporter.new(setting)
    exporter.export(@exercise)
    redirect_to verb_transformation_exercise_path(@exercise), notice: re_add ? "Re-added to Anki." : "Added to Anki."
  rescue => e
    redirect_to verb_transformation_exercise_path(@exercise), alert: "Anki export failed: #{e.message}"
  end

  private

  def set_exercise
    @exercise = VerbTransformationExercise.find(params[:id])
  end

  def exercise_params
    params.expect(verb_transformation_exercise: [
      :verb_jp, :verb_en, :verb_reading,
      :target_form,
      :answer_jp, :answer_en, :answer_reading,
      :notes, :difficulty_level
    ])
  end
end
