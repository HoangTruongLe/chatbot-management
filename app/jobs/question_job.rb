class QuestionJob < ApplicationJob
  def perform(copied_message, msg_cnt)
    question = Question.find_by_id(msg_cnt.content_id)
    built_question = copied_message.questions.build(question.dup.attributes)
    built_question.save
    if question.answers.size > 0
      question.answers.each do |answer|
        built_answer = built_question.answers.build(answer.dup.attributes)
        built_answer.save
      end
    end
    copied_message.questions
  end
end
