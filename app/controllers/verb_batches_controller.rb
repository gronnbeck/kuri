# frozen_string_literal: true

class VerbBatchesController < ApplicationController
  def index
    @batches = Batch.verb.order(created_at: :desc)
    render Views::VerbBatches::Index.new(batches: @batches)
  end

  def new
    render Views::VerbBatches::New.new
  end

  def create
    count       = params[:count].to_i.clamp(1, 100)
    difficulty  = params[:difficulty].presence || "n5"
    target_form = params[:target_form].presence

    batch = Batch.create!(
      kind: :verb, total: count,
      difficulty: difficulty, target_form: target_form
    )
    count.times { batch.batch_items.create! }
    BatchGenerationJob.perform_later(batch.id)
    redirect_to verb_batch_path(batch)
  end

  def show
    @batch = Batch.find(params[:id])
    render Views::VerbBatches::Show.new(batch: @batch)
  end
end
