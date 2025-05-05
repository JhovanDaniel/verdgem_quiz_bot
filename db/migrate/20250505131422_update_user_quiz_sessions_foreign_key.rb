class UpdateUserQuizSessionsForeignKey < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :quiz_sessions, :users, if_exists: true
    
    add_foreign_key :quiz_sessions, :users, on_delete: :cascade
  end
end
