# frozen_string_literal: true

class BatchChannel < ApplicationCable::Channel
  def subscribed
    batch = Batch.find_by(id: params[:batch_id])
    if batch
      stream_from batch.stream_name
    else
      reject
    end
  end

  def unsubscribed; end
end
