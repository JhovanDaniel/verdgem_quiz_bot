class UserLevelProgress < ApplicationRecord
  belongs_to :user
  belongs_to :level
  
  validates :user_id, uniqueness: { scope: :level_id }
  validates :attempts, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :best_score, presence: true, numericality: { in: 0..100 }
  
  def mark_completed!(score)
    update!(
      completed: true,
      completed_at: Time.current,
      best_score: [best_score, score].max
    )
  end
  
  def increment_attempt!(score)
    increment!(:attempts)
    update!(best_score: [best_score, score].max) if score > best_score
  end
  
  def completion_date
    completed_at&.strftime("%B %d, %Y")
  end
  
  def status
    return :completed if completed?
    return :struggling if attempts >= 3
    return :in_progress if attempts > 0
    :not_started
  end
  
  def performance_level
    case best_score
    when 90..100 then :excellent
    when 80..89 then :good
    when 70..79 then :satisfactory
    when 60..69 then :needs_improvement
    else :poor
    end
  end
  
  def performance_text
    case performance_level
    when :excellent then "Excellent"
    when :good then "Good"
    when :satisfactory then "Satisfactory"  
    when :needs_improvement then "Needs Improvement"
    when :poor then "Poor"
    end
  end
  
  
end
