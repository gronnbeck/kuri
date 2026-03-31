# frozen_string_literal: true

class SparringController < ApplicationController
  def index
    conversations = SparringConversation.where.not(history: [ "[]", nil ])
      .order(updated_at: :desc)
    render Views::Sparring::Index.new(conversations: conversations, current_id: session[:sparring_conversation_id])
  end

  def show
    render Views::Sparring::Show.new(conversation: current_conversation)
  end

  def resume
    conversation = SparringConversation.find(params[:id])
    session[:sparring_conversation_id] = conversation.id
    redirect_to sparring_path
  end

  def chat
    message = params[:message].to_s.strip
    return redirect_to sparring_path if message.blank?

    conversation = current_conversation
    response = SparringService.call(message: message, history: conversation.history)

    conversation.history = conversation.history + [
      { "role" => "user",      "content" => message },
      { "role" => "assistant", "content" => response }
    ]
    conversation.save!

    render Views::Sparring::Show.new(conversation: conversation)
  rescue => e
    render Views::Sparring::Show.new(conversation: current_conversation, error: e.message)
  end

  def new_conversation
    session.delete(:sparring_conversation_id)
    redirect_to sparring_path
  end

  private

  def current_conversation
    id = session[:sparring_conversation_id]
    conversation = id ? SparringConversation.find_by(id: id) : nil

    unless conversation
      conversation = SparringConversation.create!(history: [])
      session[:sparring_conversation_id] = conversation.id
    end

    conversation
  end
end
