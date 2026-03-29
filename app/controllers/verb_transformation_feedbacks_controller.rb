# frozen_string_literal: true

class VerbTransformationFeedbacksController < ApplicationController
  before_action :set_exercise

  def create
    @exercise.verb_transformation_feedbacks.create!(body: params[:body])
    redirect_to verb_transformation_exercise_path(@exercise), notice: "Feedback saved."
  rescue => e
    redirect_to verb_transformation_exercise_path(@exercise), alert: "Could not save feedback: #{e.message}"
  end

  def destroy
    @exercise.verb_transformation_feedbacks.find(params[:id]).destroy
    redirect_to verb_transformation_exercise_path(@exercise), notice: "Feedback removed."
  end

  private

  def set_exercise
    @exercise = VerbTransformationExercise.find(params[:verb_transformation_exercise_id])
  end
end
