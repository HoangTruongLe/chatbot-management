class ChatbotEmotion < ApplicationRecord
  has_many :text_messages
  has_many :questions
end
