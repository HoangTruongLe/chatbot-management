class CreateQuestionDescriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :question_descriptions do |t|
      t.references :question
      t.text :content
      t.timestamps
    end
  end
end
