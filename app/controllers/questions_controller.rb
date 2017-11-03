class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: [:update, :destroy]

  def create
    @template_id = params[:question][:question_id]
    @question = Question.new(question_params)
    respond_to do |format|
      if @question.save
        add_updated_user(question_params[:message_id])
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
      if @question.update_attributes(question_params)
        add_updated_user(question_params[:message_id])
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
      add_updated_user(set_question.message_id)
      if @question.destroy
        format.html
        format.js
      else
        format.html
        format.js
      end
    end
  end

  private

  def set_question
    @question = Question.find_by_id(params[:id])
  end

  def question_params
    params.require(:question).permit(:id, :message_id, :content, :chatbot_emotion_id,
                                  answers_attributes: [:id, :content, :done, :_destroy,  :keyword => []])
  end

end
