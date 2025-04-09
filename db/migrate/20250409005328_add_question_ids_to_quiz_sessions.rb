class AddQuestionIdsToQuizSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :quiz_sessions, :question_ids, :text
  end
end
