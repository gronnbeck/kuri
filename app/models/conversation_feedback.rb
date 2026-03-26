# frozen_string_literal: true

class ConversationFeedback < ApplicationRecord
  belongs_to :conversation_exercise
  validates :body, presence: true
end
