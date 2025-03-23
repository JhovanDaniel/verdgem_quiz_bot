class AddQuizTrackingToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :quiz_attempts, :integer, default: 0
    add_column :users, :max_quiz_attempts, :integer, default: 30
  end
end
