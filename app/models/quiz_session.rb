class QuizSession < ApplicationRecord
  belongs_to :user
  belongs_to :subject
  belongs_to :topic, optional: true
  has_many :question_attempts, dependent: :nullify
  
  def completion_percentage
    return 0 if max_score.nil? || max_score == 0
    ((total_score.to_f / max_score) * 100).round
  end
  
  def completed?
    completed_at.present?
  end
end