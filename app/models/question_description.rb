class QuestionDescription < ApplicationRecord
  belongs_to :question, optional: true
  self.inheritance_column = :_type_disabled

  enum description_type: {"メッセージ" => 0, "画像" => 1, "動画" => 2}
end
