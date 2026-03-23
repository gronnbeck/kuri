# frozen_string_literal: true

class AnkiExport < ApplicationRecord
  belongs_to :conversation_exercise

  enum :status, { pending: "pending", success: "success", failed: "failed" }
end
