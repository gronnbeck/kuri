# frozen_string_literal: true

class Batch < ApplicationRecord
  belongs_to :context, optional: true
  has_many :batch_items, dependent: :destroy

  enum :kind,   { conversation: "conversation", verb: "verb" }
  enum :status, { pending: "pending", running: "running", completed: "completed", failed: "failed" }

  validates :kind, :total, :difficulty, presence: true

  def stream_name
    "batch_#{id}"
  end

  def done?
    completed? || failed?
  end

  def progress_percent
    return 0 if total.zero?
    ((completed_count + failed_count).to_f / total * 100).round
  end
end
