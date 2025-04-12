class QuizSession < ApplicationRecord
  serialize :question_ids, coder: YAML
  
  default_scope { where(archived: false) }
  
  belongs_to :user
  belongs_to :subject
  belongs_to :topic, optional: true
  has_many :question_attempts, dependent: :destroy
  has_one :feedback, dependent: :destroy
  
  def total_questions
    # This gets the question_ids from the question_attempts
    question_ids = question_attempts.pluck(:question_id)
    question_ids.uniq.count
  end
  
  def completed_questions
    # Only count questions that have been attempted
    question_attempts.where.not(score: nil).count
  end
  
  def completion_percentage
    return 0 if max_score.nil? || max_score == 0
    ((total_score.to_f / max_score) * 100).round
  end
  
  def completed?
    completed_at.present?
  end
  
  def score_percentage
    return 0 if max_score.nil? || max_score == 0
    ((total_score.to_f / max_score) * 100).round
  end
  
end