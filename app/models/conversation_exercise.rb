# frozen_string_literal: true

class ConversationExercise < ApplicationRecord
  belongs_to :context, optional: true

  has_many :conversation_feedbacks, dependent: :destroy
  has_many :conversation_audios, dependent: :destroy
  has_one :request_audio, -> { where(kind: "request") }, class_name: "ConversationAudio"
  has_one :response_audio, -> { where(kind: "response") }, class_name: "ConversationAudio"

  has_many :anki_exports, dependent: :destroy

  enum :difficulty_level, { n5: "n5", n4: "n4", n3: "n3", n2: "n2", n1: "n1" }
  enum :anki_status, { not_added: "not_added", added: "added", failed: "failed" }

  validates :request_jp, :response_jp, :difficulty_level, presence: true
end
