class CreateQuestionAttempts < ActiveRecord::Migration[7.1]
  def change
    create_table :question_attempts, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :question, null: false, foreign_key: true, type: :uuid
      t.text :student_answer
      t.integer :score
      t.text :feedback

      t.timestamps
    end
  end
end
