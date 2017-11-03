class Answer < ApplicationRecord
  belongs_to :question, optional: true
  has_one :message
  before_save do
    self.keyword = keyword.reject(&:empty?)
  end
  # validates :content, presence: true
end
