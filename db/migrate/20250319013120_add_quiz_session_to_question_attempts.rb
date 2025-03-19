class AddQuizSessionToQuestionAttempts < ActiveRecord::Migration[7.1]
  def change
    add_reference :question_attempts, :quiz_session, foreign_key: true, type: :uuid
  end
end
