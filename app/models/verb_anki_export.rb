# frozen_string_literal: true

class VerbAnkiExport < ApplicationRecord
  belongs_to :verb_transformation_exercise
  enum :status, { pending: "pending", success: "success", failed: "failed" }
end
