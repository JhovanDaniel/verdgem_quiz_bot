class AddQuestionCountToQuizSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :quiz_sessions, :question_count, :integer
  end
end
