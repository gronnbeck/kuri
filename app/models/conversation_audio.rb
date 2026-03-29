# frozen_string_literal: true

class ConversationAudio < ApplicationRecord
  belongs_to :conversation_exercise
  belongs_to :actor, optional: true

  has_one_attached :audio

  enum :kind, { request: "request", response: "response" }

  validates :kind, presence: true
end
