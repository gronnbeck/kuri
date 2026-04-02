# frozen_string_literal: true

class PhraseCard < ApplicationRecord
  has_one_attached :audio
  has_many :phrase_anki_exports, dependent: :destroy

  enum :anki_status, { not_added: "not_added", added: "added", failed: "failed" }

  DIFFICULTIES = %w[n5 n4 n3 n2 n1].freeze

  validates :english, :japanese, :hiragana, :difficulty_level, presence: true
  validates :difficulty_level, inclusion: { in: DIFFICULTIES }
  validates :japanese, uniqueness: true
end
