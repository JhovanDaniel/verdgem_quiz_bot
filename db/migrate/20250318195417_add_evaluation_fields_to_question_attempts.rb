class AddEvaluationFieldsToQuestionAttempts < ActiveRecord::Migration[7.1]
  def change
    add_column :question_attempts, :evaluation_status, :string, default: "pending"
    add_column :question_attempts, :evaluation_error, :text
  end
end
