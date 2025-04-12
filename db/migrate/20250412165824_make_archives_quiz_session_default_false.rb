class MakeArchivesQuizSessionDefaultFalse < ActiveRecord::Migration[7.1]
  def change
    change_column :quiz_sessions, :archived, :boolean, default: false
  end
end
