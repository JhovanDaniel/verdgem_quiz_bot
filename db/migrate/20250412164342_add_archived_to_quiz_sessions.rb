class AddArchivedToQuizSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :quiz_sessions, :archived, :boolean
  end
end
