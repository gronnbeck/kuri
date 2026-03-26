# frozen_string_literal: true

class ConversationFeedbacksController < ApplicationController
  before_action :set_exercise

  def create
    @exercise.conversation_feedbacks.create!(body: params[:body])
    redirect_to conversation_exercise_path(@exercise), notice: "Feedback saved."
  rescue ActiveRecord::RecordInvalid
    redirect_to conversation_exercise_path(@exercise), alert: "Feedback cannot be blank."
  end

  def destroy
    @exercise.conversation_feedbacks.find(params[:id]).destroy
    redirect_to conversation_exercise_path(@exercise), notice: "Feedback removed."
  end

  private

  def set_exercise
    @exercise = ConversationExercise.find(params[:conversation_exercise_id])
  end
end
