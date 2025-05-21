class AddSubTopicToQuizSessions < ActiveRecord::Migration[7.1]
  def change
    add_reference :quiz_sessions, :sub_topic, type: :uuid, foreign_key: true
  end
end
