# frozen_string_literal: true

require "test_helper"

class ActorTest < ActiveSupport::TestCase
  # --- pick_random ---

  test "pick_random returns nil when no actors exist" do
    assert_nil Actor.pick_random
  end

  test "pick_random returns the only actor when one exists" do
    actor = Actor.create!(voice_id: "voice-1")
    assert_equal actor, Actor.pick_random
  end

  test "pick_random with exclude_id returns the other actor when two exist" do
    a1 = Actor.create!(voice_id: "voice-1")
    a2 = Actor.create!(voice_id: "voice-2")

    result = Actor.pick_random(exclude_id: a1.id)
    assert_equal a2, result
  end

  test "pick_random with exclude_id returns the excluded actor when it is the only one" do
    actor = Actor.create!(voice_id: "voice-1")
    assert_equal actor, Actor.pick_random(exclude_id: actor.id)
  end

  test "pick_random with exclude_id never returns the excluded actor when alternatives exist" do
    a1 = Actor.create!(voice_id: "voice-1")
    _  = Actor.create!(voice_id: "voice-2")
    _  = Actor.create!(voice_id: "voice-3")

    # Run many times to rule out lucky draws
    results = 20.times.map { Actor.pick_random(exclude_id: a1.id) }
    assert results.none? { |a| a.id == a1.id }
  end
end
