# frozen_string_literal: true

class ConversationBatchesController < ApplicationController
  def index
    @batches = Batch.conversation.order(created_at: :desc)
    render Views::ConversationBatches::Index.new(batches: @batches)
  end

  def new
    @contexts = Context.order(:name)
    render Views::ConversationBatches::New.new(contexts: @contexts)
  end

  def create
    count      = params[:count].to_i.clamp(1, 100)
    difficulty = params[:difficulty].presence || "n5"
    context    = params[:context_id].present? ? Context.find(params[:context_id]) : nil

    batch = Batch.create!(
      kind: :conversation, total: count,
      difficulty: difficulty, context: context
    )
    count.times { batch.batch_items.create! }
    BatchGenerationJob.perform_later(batch.id)
    redirect_to conversation_batch_path(batch)
  end

  def show
    @batch = Batch.find(params[:id])
    render Views::ConversationBatches::Show.new(batch: @batch)
  end
end
