class UpdateQuestionAttemptsUserForeignKey < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :question_attempts, :users
    
    add_foreign_key :question_attempts, :users, on_delete: :cascade
  end
end
