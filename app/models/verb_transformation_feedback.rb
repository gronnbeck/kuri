# frozen_string_literal: true

class VerbTransformationFeedback < ApplicationRecord
  belongs_to :verb_transformation_exercise
  validates :body, presence: true
end
