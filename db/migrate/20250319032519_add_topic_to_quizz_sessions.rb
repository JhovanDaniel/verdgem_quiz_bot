class AddTopicToQuizzSessions < ActiveRecord::Migration[7.1]
  def change
    remove_column :quiz_sessions, :topic_id
    add_reference :quiz_sessions, :topic, foreign_key: true, type: :uuid
  end
end
