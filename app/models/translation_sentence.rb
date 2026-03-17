# frozen_string_literal: true

class TranslationSentence < ApplicationRecord
  validates :english, presence: true
  validates :japanese, presence: true
end
