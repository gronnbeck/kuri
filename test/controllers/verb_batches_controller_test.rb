# frozen_string_literal: true

require "test_helper"

class VerbBatchesControllerTest < ActionDispatch::IntegrationTest
  test "new renders the form" do
    get new_verb_batch_path
    assert_response :success
  end

  test "create enqueues a job and redirects to show" do
    assert_enqueued_with(job: BatchGenerationJob) do
      post verb_batches_path, params: { count: "10", difficulty: "n4", target_form: "te_form" }
    end

    batch = Batch.last
    assert_redirected_to verb_batch_path(batch)
    assert_equal "verb",    batch.kind
    assert_equal 10,        batch.total
    assert_equal "n4",      batch.difficulty
    assert_equal "te_form", batch.target_form
    assert_equal 10,        batch.batch_items.count
  end

  test "create stores nil target_form when blank" do
    assert_enqueued_with(job: BatchGenerationJob) do
      post verb_batches_path, params: { count: "5", difficulty: "n5", target_form: "" }
    end

    assert_nil Batch.last.target_form
  end

  test "show renders a pending batch" do
    batch = Batch.create!(kind: :verb, total: 10, difficulty: "n5")

    get verb_batch_path(batch)

    assert_response :success
  end

  test "index lists verb batches only" do
    Batch.create!(kind: :verb,         total: 5,  difficulty: "n5")
    Batch.create!(kind: :conversation, total: 10, difficulty: "n4")

    get verb_batches_path

    assert_response :success
    assert_equal 1, Batch.verb.count
  end
end
