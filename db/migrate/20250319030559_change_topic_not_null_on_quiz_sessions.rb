class ChangeTopicNotNullOnQuizSessions < ActiveRecord::Migration[7.1]
  def change
    change_column :quiz_sessions, :topic_id, :uuid
  end
end
