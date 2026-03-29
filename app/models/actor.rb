# frozen_string_literal: true

class Actor < ApplicationRecord
  has_many :clips, dependent: :destroy

  enum :gender, { female: "female", male: "male" }, prefix: true

  validates :voice_id, presence: true

  def display_name
    name.presence || "NoNameYet"
  end
end
