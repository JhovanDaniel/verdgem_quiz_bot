class AddHasProblemToQuestionAttempts < ActiveRecord::Migration[7.1]
  def change
    add_column :question_attempts, :has_problem, :boolean, default: false
  end
end
