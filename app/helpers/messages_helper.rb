module MessagesHelper
  def answers_by_question(question)
    question.answers.map(&:content).join("<br>")
  end
end
