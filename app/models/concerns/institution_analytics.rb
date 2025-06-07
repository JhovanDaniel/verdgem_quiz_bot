module InstitutionAnalytics
  extend ActiveSupport::Concern
  
  def executive_summary(period = 30.days)
    {
      active_students: institution_active_students_count(period),
      completion_rate: institution_quiz_completion_rate(period),
      institution_average_score: institution_average_score(period),
      growth_rate: calculate_growth_rate(period),
      institution_total_students: users.where(role: :student, institution_id: id).count,
      total_quizzes_completed: institution_completed_quizzes_count(period),
      platform_engagement_score: platform_engagement_score(period)
    }
  end
  
  
  # ============================================================================
  # EXECUTIVE SUMMARY HELPER METHODS
  # ============================================================================
  
  def institution_active_students_count(period)
    users.where(role: :student, institution_id: id).joins(:quiz_sessions)
            .where(quiz_sessions: { started_at: period_range(period) })
            .distinct
            .count
  end
  
  def institution_quiz_completion_rate(period)
    sessions = institution_quiz_sessions_in_period(period)
    return 0 if sessions.empty?
    
    completed_count = sessions.where.not(completed_at: nil).count
    (completed_count.to_f / sessions.count * 100).round(1)
  end
  
  def institution_average_score(period)
    completed_sessions = institution_quiz_sessions_in_period(period)
                        .where.not(completed_at: nil, total_score: nil, max_score: nil)
                        .where('max_score > 0')
    
    return 0 if completed_sessions.empty?
    
    completed_sessions.average('total_score::float / max_score * 100')&.round(1) || 0
  end
  
  def institution_completed_quizzes_count(period)
    institution_quiz_sessions_in_period(period).where.not(completed_at: nil).count
  end
  
  
  # ============================================================================
  # UTILITY METHODS
  # ============================================================================
  
  def period_range(period)
    case period
    when Range
      period
    when ActiveSupport::Duration
      period.ago..Time.current
    else
      30.days.ago..Time.current
    end
  end
  
  def calculate_previous_period(period)
    range = period_range(period)
    duration = range.end - range.begin
    (range.begin - duration)..range.begin
  end
  
  def institution_quiz_sessions_in_period(period)
    QuizSession.joins(:user)
           .where(users: { institution_id: id }).where(started_at: period_range(period))
  end
  
end