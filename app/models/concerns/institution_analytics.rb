module InstitutionAnalytics
  extend ActiveSupport::Concern
  
  def executive_summary(period = 30.days)
    {
      total_active_students: active_students_count(period),
      overall_completion_rate: overall_quiz_completion_rate(period),
      institution_average_score: institution_average_score(period),
      total_learning_hours: total_learning_hours(period),
      growth_rate: calculate_growth_rate(period),
      total_students: users.where(role: :student, institution_id: id).count,
      total_quizzes_completed: completed_quizzes_count(period),
      platform_engagement_score: platform_engagement_score(period)
    }
  end
  
  
  
end