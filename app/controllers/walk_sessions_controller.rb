# frozen_string_literal: true

class WalkSessionsController < ApplicationController
  before_action :set_session, only: [ :show, :edit, :update, :destroy, :generate, :audio ]

  def index
    @sessions = WalkSession.order(created_at: :desc)
    render Views::WalkSessions::Index.new(sessions: @sessions)
  end

  def new
    render Views::WalkSessions::New.new(session: WalkSession.new)
  end

  def create
    @walk_session = WalkSession.new(session_params)
    if @walk_session.save
      redirect_to walk_session_path(@walk_session)
    else
      render Views::WalkSessions::New.new(session: @walk_session), status: :unprocessable_entity
    end
  end

  def show
    conversations = ConversationExercise.includes(:context, :conversation_audios).where(archived: false).order(:difficulty_level, :created_at)
    phrases       = PhraseCard.where(archived: false).order(:difficulty_level, :created_at)
    verbs         = VerbTransformationExercise.where(archived: false).order(:difficulty_level, :created_at) rescue []
    render Views::WalkSessions::Show.new(
      walk_session:  @walk_session,
      conversations: conversations,
      phrases:       phrases,
      verbs:         verbs
    )
  end

  def edit
    render Views::WalkSessions::Edit.new(session: @walk_session)
  end

  def update
    if @walk_session.update(session_params)
      redirect_to walk_session_path(@walk_session), notice: "Updated."
    else
      render Views::WalkSessions::Edit.new(session: @walk_session), status: :unprocessable_entity
    end
  end

  def destroy
    @walk_session.audio.purge if @walk_session.audio.attached?
    @walk_session.destroy
    redirect_to walk_sessions_path, notice: "Session deleted."
  end

  def generate
    @walk_session.update!(status: :processing)
    @walk_session.audio.purge if @walk_session.audio.attached?
    WalkAudioBuilder.call(@walk_session)
    redirect_to walk_session_path(@walk_session), notice: "Audio generated — enjoy your walk!"
  rescue => e
    redirect_to walk_session_path(@walk_session), alert: "Generation failed: #{e.message}"
  end

  def audio
    redirect_to rails_blob_url(@walk_session.audio), allow_other_host: true
  end

  private

  def set_session
    @walk_session = WalkSession.find(params[:id])
  end

  def session_params
    params.expect(walk_session: [ :name, :inner_pause_ms, :outer_pause_ms ])
  end
end
