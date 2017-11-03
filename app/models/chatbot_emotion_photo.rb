class ChatbotEmotionPhoto < ApplicationRecord
  belongs_to :chatbot
  has_attached_file :avatar, path: "app/images/:id/:filename", :default_url => "/assets/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
  attr_accessor :image_url

  def image_url
    avatar.url(:thumb)
  end
end
