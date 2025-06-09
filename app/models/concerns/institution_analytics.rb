module InstitutionAnalytics
  extend ActiveSupport::Concern
  
  def executive_summary(period = 30.days)
    {
      total_students: institution_total_students_count(period),
      institution_average_score: institution_average_score(period),
      growth_rate: calculate_growth_rate(period),
      institution_total_students: users.where(role: :student, institution_id: id).count,
      total_quizzes_completed: institution_completed_quizzes_count(period),
      total_quizzes: institution_quizzes_count(period),
      total_questions_completed: institution_completed_questions_count(period),
      number_subjects_done: institution_subjects_done_count(period),
      platform_engagement_score: platform_engagement_score(period),
    }
  end
  
  def student_engagement_analytics(period = 30.days)
    {
      active_students: institution_active_students_count(period),
      login_frequency: student_login_frequency(period),
      completion_rate: institution_quiz_completion_rate(period).round(0),
      avg_quiz_completion: institution_averge_quiz_completion(period).round(0),
    }
  end
  
  def quiz_performance_analytics(period = 30.days)
    {
      active_students: institution_active_students_count(period),
      total_easy_questions: institution_easy_questions_count(period),
      easy_questions_rate: institution_easy_questions_rate(period),
      total_medium_questions: institution_medium_questions_count(period),
      medium_questions_rate: institution_medium_questions_rate(period),
      total_hard_questions: institution_hard_questions_count(period),
      hard_questions_rate: institution_hard_questions_rate(period),
      avg_completion_time: institution_average_quiz_completion_time(period)
    }
  end
  
  def subjects_analysis(period)
    
    {
      total_subject_quizzes: institution_subject_quiz_count(subject, period)
    }
  end
  
  
  # ============================================================================
  # EXECUTIVE SUMMARY HELPER METHODS
  # ============================================================================
  
  def institution_total_students_count(period)
    users.where(role: :student, institution_id: id).joins(:quiz_sessions)
            .distinct
            .count
  end
  
  def institution_average_score(period)
    completed_sessions = institution_quiz_sessions_in_period(period)
                        .where.not(completed_at: nil, total_score: nil, max_score: nil)
                        .where('max_score > 0')
    
    return 0 if completed_sessions.empty?
    
    completed_sessions.average('total_score::float / max_score * 100')&.round(1) || 0
  end
  
  def institution_quizzes_count(period)
    institution_quiz_sessions_in_period(period).count
  end
  
  def institution_completed_quizzes_count(period)
    institution_quiz_sessions_in_period(period).where.not(completed_at: nil).count
  end
  
  def institution_completed_questions_count(period)
    institution_quiz_sessions_in_period(period).where.not(completed_at: nil).joins(:question_attempts).count
  end
  
  def institution_subjects_done_count(period)
    institution_quiz_sessions_in_period(period).where.not(completed_at: nil)
    .joins(:subject)
    .distinct
    .count('subjects.id')
  end
  
  def institution_top_subject(period)
    
  end
  
  def institution_bottom_subject(period)
    
  end
  
  # ============================================================================
  # STUDENT ENGAGEMENT ANALYTICS HELPER METHODS  
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
  
  def institution_averge_quiz_completion(period)
    avg = institution_completed_quizzes_count(period)/institution_active_students_count(period)
  end
  
  
  # ============================================================================
  # QUIZ PERFORMANCE HELPER METHODS
  # ============================================================================
  
  def institution_easy_questions_count(period)
    institution_quiz_sessions_in_period(period).where.not(completed_at: nil)
    .joins(question_attempts: :question)
    .where(questions: { difficulty_level: 'easy' })
    .count('question_attempts.id')
  end
  
  def institution_easy_questions_rate(period)
    easy_rate = institution_easy_questions_count(period)/institution_completed_questions_count(period)
    easy_rate = (easy_rate * 100).round(1)
  end
  
  def institution_medium_questions_count(period)
    institution_quiz_sessions_in_period(period).where.not(completed_at: nil)
    .joins(question_attempts: :question)
    .where(questions: { difficulty_level: 'medium' })
    .count('question_attempts.id')
  end
  
  def institution_medium_questions_rate(period)
    medium_rate = institution_medium_questions_count(period)/institution_completed_questions_count(period)
    medium_rate = (medium_rate * 100).round(1)
  end
  
  def institution_hard_questions_count(period)
    institution_quiz_sessions_in_period(period).where.not(completed_at: nil)
    .joins(question_attempts: :question)
    .where(questions: { difficulty_level: 'hard' })
    .count('question_attempts.id')
  end
  
  def institution_hard_questions_rate(period)
    hard_rate = institution_hard_questions_count(period)/institution_completed_questions_count(period)
    hard_rate = (hard_rate * 100).round(1)
  end
  
  def institution_average_quiz_completion_time(period)
    completed_sessions = institution_quiz_sessions_in_period(period).where.not(completed_at: nil)
    
    return 0 if completed_sessions.empty?
    
    total_duration_seconds = completed_sessions.sum do |session|
      duration = session.completed_at - session.created_at
      # Filter out unrealistic durations (negative or more than 4 hours)
      duration.between?(0, 4.hours) ? duration : 0
    end
    
    # Return average in minutes
    (total_duration_seconds / completed_sessions.count / 1.minute).round(2)
  end

  #===========================================================================
  # SUBJECT ANALYSIS HELPER METHODS
  # ==========================================================================
  
  def institution_subject_quiz_count(subject, period)
    QuizSession.joins(:user)
             .where(users: { institution_id: id, role: :student })
             .where(subject: subject)
             .where(started_at: period_range(period))
             .count
  end
  
  def institution_subject_average_score(subject, period)
    completed_sessions = QuizSession.joins(:user)
                                   .where(users: { institution_id: id, role: :student })
                                   .where(subject: subject)
                                   .where(started_at: period_range(period))
                                   .where.not(completed_at: nil, total_score: nil, max_score: nil)
                                   .where('max_score > 0')
    
    return 0 if completed_sessions.empty?
    
    completed_sessions.average('total_score::float / max_score * 100')&.round(1) || 0
  end
  
  def institution_subject_participation_rate(subject, period)
    # Get total active students in the institution for this period
    total_active_students = active_students_count(period)
    
    return 0 if total_active_students == 0
    
    # Get unique students who attempted quizzes in this subject
    students_in_subject = QuizSession.joins(:user)
                                    .where(users: { institution_id: id, role: :student  })
                                    .where(subject: subject)
                                    .where(started_at: period_range(period))
                                    .distinct
                                    .count('users.id')
    
    # Calculate participation rate as percentage
    (students_in_subject.to_f / total_active_students * 100).round(1)
  end
  
  def institution_subject_average_quiz_completion_time(subject, period)
    completed_sessions = institution_quiz_sessions_in_period(period).where.not(completed_at: nil)
    completed_sessions = completed_sessions.where(subject_id: subject)
    
    return 0 if completed_sessions.empty?
    
    total_duration_seconds = completed_sessions.sum do |session|
      duration = session.completed_at - session.created_at
      # Filter out unrealistic durations (negative or more than 4 hours)
      duration.between?(0, 4.hours) ? duration : 0
    end
    
    # Return average in minutes
    (total_duration_seconds / completed_sessions.count / 1.minute).round(2)
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