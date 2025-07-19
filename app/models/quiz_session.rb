class QuizSession < ApplicationRecord
  serialize :question_ids, coder: YAML
  
  default_scope { where(archived: false) }
  scope :completed, -> { where.not(completed_at: nil) }
  
  belongs_to :user
  belongs_to :subject
  belongs_to :topic, optional: true
  belongs_to :sub_topic, optional: true
  belongs_to :level, optional: true
  has_many :question_attempts, dependent: :destroy
  has_one :feedback, dependent: :destroy
  
  #after_update :update_level_progress, if: :completed_at_changed?
  
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
  
  def passed?
    return false unless level.present?
    score_percentage >= level.passing_score_percentage
  end
  
  def update_level_progress
    return unless completed_at.present? && level.present?
    
    Rails.logger.info "Updating level progress for user #{user.id}, level #{level.id}"
    
    # Find or create progress record for this user/level combination
    progress = UserLevelProgress.find_or_create_by(
      user: user, 
      level: level
    ) do |new_progress|
      # This block runs only when creating a new record
      new_progress.attempts = 0
      new_progress.best_score = 0
      new_progress.completed = false
    end
    
    # Increment attempt count
    progress.increment!(:attempts)
    Rails.logger.info "Incremented attempts to #{progress.attempts}"
    
    # Update best score if this attempt was better
    current_score = score_percentage
    if current_score > progress.best_score
      progress.update!(best_score: current_score)
      Rails.logger.info "Updated best score to #{current_score}"
    end
    
    # Mark as completed if they passed and haven't completed before
    if passed? && !progress.completed?
      progress.update!(
        completed: true,
        completed_at: Time.current
      )
      
      Rails.logger.info "Marked level #{level.name} as completed for user #{user.id}"
      
      # Optional: Trigger any completion side effects
      #handle_level_completion(progress)
    else
      Rails.logger.info "Level not completed - Score: #{current_score}%, Required: #{level.passing_score_percentage}%"
    end
    
    progress
  end
  
  private

  
end