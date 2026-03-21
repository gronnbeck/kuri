# frozen_string_literal: true

class Sentence < ApplicationRecord
  has_many :clips, dependent: :destroy

  validates :text, presence: true, uniqueness: true
end
