# frozen_string_literal: true

class WalkSessionItemsController < ApplicationController
  before_action :set_walk_session
  before_action :set_item, only: [ :destroy, :move_up, :move_down ]

  def create
    item_type = params[:item_type].to_s
    item_id   = params[:item_id].to_i

    unless WalkSessionItem::ALLOWED_TYPES.include?(item_type)
      redirect_to walk_session_path(@walk_session), alert: "Invalid item type."
      return
    end

    next_pos = (@walk_session.walk_session_items.maximum(:position) || -1) + 1
    @walk_session.walk_session_items.create!(
      item_type: item_type,
      item_id:   item_id,
      position:  next_pos
    )
    @walk_session.update_columns(status: "pending") if @walk_session.ready?
    redirect_to walk_session_path(@walk_session)
  end

  def destroy
    @item.destroy
    reorder!
    redirect_to walk_session_path(@walk_session)
  end

  def move_up
    swap_with_neighbour(-1)
    redirect_to walk_session_path(@walk_session)
  end

  def move_down
    swap_with_neighbour(+1)
    redirect_to walk_session_path(@walk_session)
  end

  private

  def set_walk_session
    @walk_session = WalkSession.find(params[:walk_session_id])
  end

  def set_item
    @item = @walk_session.walk_session_items.find(params[:id])
  end

  def reorder!
    @walk_session.walk_session_items.order(:position).each_with_index do |item, idx|
      item.update_columns(position: idx)
    end
  end

  def swap_with_neighbour(direction)
    items = @walk_session.walk_session_items.order(:position).to_a
    idx   = items.index(@item)
    return unless idx

    neighbour_idx = idx + direction
    return unless neighbour_idx.between?(0, items.size - 1)

    neighbour = items[neighbour_idx]
    @item.update_columns(position: neighbour.position)
    neighbour.update_columns(position: @item.position)
  end
end
