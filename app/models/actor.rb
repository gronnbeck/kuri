# frozen_string_literal: true

class Actor < ApplicationRecord
  has_many :clips, dependent: :destroy
  has_many :conversation_audios, dependent: :nullify
  has_many :verb_audios, dependent: :nullify

  enum :gender, { female: "female", male: "male" }, prefix: true

  validates :voice_id, presence: true

  # Returns a random actor. When +exclude_id+ is given and more than one actor
  # exists, the excluded actor is omitted from the pool.
  def self.pick_random(exclude_id: nil)
    pool = exclude_id && count > 1 ? where.not(id: exclude_id) : all
    pool.order(Arel.sql("RANDOM()")).first
  end

  def display_name
    name.presence || "NoNameYet"
  end
end
