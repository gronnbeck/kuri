# frozen_string_literal: true

class Actor < ApplicationRecord
  has_many :clips, dependent: :destroy

  validates :voice_id, presence: true

  def display_name
    name.presence || "NoNameYet"
  end
end
