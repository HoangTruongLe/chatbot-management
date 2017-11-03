class AddTypeToQuestionDescription < ActiveRecord::Migration[5.1]
  def change
    add_column :question_descriptions, :type, :integer
  end
end
