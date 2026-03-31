# frozen_string_literal: true

class SparringConversation < ApplicationRecord
  def history
    JSON.parse(self[:history] || "[]")
  end

  def history=(turns)
    self[:history] = turns.to_json
  end

  def first_message
    history.find { |t| t["role"] == "user" }&.dig("content")
  end

  def message_count
    history.count { |t| t["role"] == "user" }
  end

  def blank?
    message_count.zero?
  end
end
