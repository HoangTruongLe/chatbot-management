class Chatbot < ApplicationRecord
  has_many :chatbot_emotion_photos, inverse_of: :chatbot
  accepts_nested_attributes_for :chatbot_emotion_photos, reject_if: :all_blank, allow_destroy: true
  validates :name, presence: true
  validates :name, length: { maximum: 100 }
  validates :profile, length: { maximum: 200 }
  validates :rarity, length: { maximum: 100 }
  validates :tag, length: { maximum: 100 }
  belongs_to :created_user, class_name: 'User', foreign_key: 'created_user_id', optional: true
end
