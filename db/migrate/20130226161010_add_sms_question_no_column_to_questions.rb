class AddSmsQuestionNoColumnToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :sms_question_no, :integer
  end
end
