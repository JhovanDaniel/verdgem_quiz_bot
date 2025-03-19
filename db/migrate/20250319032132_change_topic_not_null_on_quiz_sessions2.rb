class ChangeTopicNotNullOnQuizSessions2 < ActiveRecord::Migration[7.1]
  def change
    remove_column :quiz_sessions, :topic_id
    add_column :quiz_sessions, :topic_id, :uuid
  end
end
