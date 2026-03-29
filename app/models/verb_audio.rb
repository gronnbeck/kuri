# frozen_string_literal: true

class VerbAudio < ApplicationRecord
  belongs_to :verb_transformation_exercise
  belongs_to :actor, optional: true
  has_one_attached :audio

  enum :kind, { verb: "verb", answer: "answer" }

  validates :kind, presence: true
end
