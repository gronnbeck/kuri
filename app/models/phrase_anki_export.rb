# frozen_string_literal: true

class PhraseAnkiExport < ApplicationRecord
  belongs_to :phrase_card

  enum :status, { pending: "pending", success: "success", failed: "failed" }
end
