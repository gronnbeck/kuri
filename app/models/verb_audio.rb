# frozen_string_literal: true

class VerbAudio < ApplicationRecord
  belongs_to :verb_transformation_exercise
  has_one_attached :audio

  enum :kind, { verb: "verb", answer: "answer" }

  validates :kind, presence: true
end
