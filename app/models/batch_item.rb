# frozen_string_literal: true

class BatchItem < ApplicationRecord
  belongs_to :batch
  belongs_to :exercise, polymorphic: true, optional: true

  enum :status, { pending: "pending", completed: "completed", failed: "failed" }
end
