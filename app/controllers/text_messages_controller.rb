class TextMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_text_message, only: [:update, :destroy]

  def create
    @template_id = params[:text_message][:text_message_id]
    @text_message = TextMessage.new(text_message_params)
    respond_to do |format|
      if @text_message.save
        add_updated_user(text_message_params[:message_id])
        format.html
        format.js
      else
        format.html
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @text_message.update_attributes(text_message_params)
        add_updated_user(text_message_params[:message_id])
        format.html
        format.js
      else
        format.html
        format.js
      end
    end
  end

  def destroy
    respond_to do |format|
      add_updated_user(set_text_message.message_id)
      if @text_message.destroy
        format.html
        format.js
      else
        format.html
        format.js
      end
    end
  end

  private

  def set_text_message
    @text_message = TextMessage.find_by_id(params[:id])
  end

  def text_message_params
    params.require(:text_message).permit(:message_id, :content, :chatbot_emotion_id)
  end
end
