# frozen_string_literal: true

require "test_helper"

class ConversationBatchesControllerTest < ActionDispatch::IntegrationTest
  test "new renders the form" do
    get new_conversation_batch_path
    assert_response :success
  end

  test "create enqueues a job and redirects to show" do
    assert_enqueued_with(job: BatchGenerationJob) do
      post conversation_batches_path, params: { count: "5", difficulty: "n4" }
    end

    batch = Batch.last
    assert_redirected_to conversation_batch_path(batch)
    assert_equal "conversation", batch.kind
    assert_equal 5,    batch.total
    assert_equal "n4", batch.difficulty
    assert_equal 5,    batch.batch_items.count
  end

  test "create clamps count to 100" do
    assert_enqueued_with(job: BatchGenerationJob) do
      post conversation_batches_path, params: { count: "999", difficulty: "n5" }
    end

    assert_equal 100, Batch.last.total
  end

  test "create defaults difficulty to n5" do
    assert_enqueued_with(job: BatchGenerationJob) do
      post conversation_batches_path, params: { count: "5" }
    end

    assert_equal "n5", Batch.last.difficulty
  end

  test "show renders a pending batch" do
    batch = Batch.create!(kind: :conversation, total: 10, difficulty: "n5")

    get conversation_batch_path(batch)

    assert_response :success
  end

  test "index lists conversation batches" do
    Batch.create!(kind: :conversation, total: 5,  difficulty: "n5")
    Batch.create!(kind: :verb,         total: 10, difficulty: "n4")

    get conversation_batches_path

    assert_response :success
    assert_equal 1, Batch.conversation.count
  end
end
