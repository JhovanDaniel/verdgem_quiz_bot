class QuestionAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :question
  belongs_to :quiz_session, optional: true
  
  validates :student_answer, presence: true
  
  # Optional: Add a method to check if this attempt was correct
  def correct?
    score.to_f / max_score.to_f >= 0.7 # Consider 70%+ as correct
  end
  
  def max_score
    question.max_points
  end
  
end