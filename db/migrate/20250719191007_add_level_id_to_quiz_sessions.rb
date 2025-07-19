class AddLevelIdToQuizSessions < ActiveRecord::Migration[7.1]
  def change
    add_reference :quiz_sessions, :level, 
                  null: true, 
                  foreign_key: true, 
                  type: :uuid
  end
end
