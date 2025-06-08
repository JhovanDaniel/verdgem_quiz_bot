class Institution < ApplicationRecord
  include InstitutionAnalytics
  
  has_many :users, dependent: :nullify
  
  has_one_attached :institution_logo, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :contact_email, presence: true
  validates :phone, presence: true
  validates :address, presence: true

  scope :active, -> { where(active: true) }
  
  def status
    if active == true
      institution_status = "<span class='badge badge-primary rounded-lg mx-2'>●</span><span class=''>Active</span>"
      institution_status.html_safe
    else
      institution_status = "<span class='badge badge-danger rounded-lg mx-2'>●</span><span class=''>Inactive</span>"
      institution_status.html_safe
    end
  end
  
  def total_students
    users.where(role: :student).count
  end
  
  def quiz_completion_rate
    total_started = QuizSession.joins(:user)
                              .where(users: { institution_id: id, role: User.roles[:student] })
                              .count

    total_completed = QuizSession.joins(:user)
                                .where(users: { institution_id: id, role: User.roles[:student] })
                                .where.not(completed_at: nil)
                                .count

    return 0 if total_started == 0
    ((total_completed.to_f / total_started) * 100).round(1)
  end
  
  def total_quizzes_completed
    QuizSession.joins(:user)
               .where(users: { institution_id: self.id, role: User.roles[:student] })
               .where.not(completed_at: nil)
               .count
  end
  
  def average_quiz_score
    QuizSession.joins(:user)
               .where(users: { institution_id: self.id, role: User.roles[:student] })
               .where.not(completed_at: nil, total_score: nil, max_score: nil)
               .where('max_score > 0')
               .average('(total_score::float / max_score::float) * 100')
               &.round(1) || 0
  end
  
  #Points statistics------------------------------
  
  def total_student_points
    # Get total points from all students' finished quizzes
    QuizSession.joins(:user)
               .where(users: { institution_id: id, role: User.roles[:student] })
               .joins(:question_attempts)
               .where.not(quiz_sessions: { completed_at: nil })
               .sum('question_attempts.score') || 0
  end
  
  def average_student_points
    student_count = students.count
    return 0 if student_count == 0
    (total_student_points.to_f / student_count).round(1)
  end
  
   # Get ranking among all institutions
  def points_ranking
    institutions_with_points = Institution.joins(:users)
     .where(users: { role: User.roles[:student] })
     .group('institutions.id')
     .select(
       'institutions.id',
       'institutions.name',
       'COALESCE(SUM(CASE 
         WHEN quiz_sessions.completed_at IS NOT NULL 
         THEN question_attempts.score 
         ELSE 0 
       END), 0) as total_points'
     )
     .joins('LEFT JOIN quiz_sessions ON quiz_sessions.user_id = users.id')
     .joins('LEFT JOIN question_attempts ON question_attempts.quiz_session_id = quiz_sessions.id')
     .order('total_points DESC')
    
    institutions_with_points.find_index { |inst| inst.id == self.id } + 1
  end
  
  #Get all institutions ranked by points
  def self.ranked_by_points(limit = nil)
    query = joins(:users)
            .where(users: { role: User.roles[:student] })
            .joins('LEFT JOIN quiz_sessions ON quiz_sessions.user_id = users.id AND quiz_sessions.completed_at IS NOT NULL')
            .joins('LEFT JOIN question_attempts ON question_attempts.quiz_session_id = quiz_sessions.id')
            .group('institutions.id')
            .select(
              'institutions.*',
              'COALESCE(SUM(question_attempts.score), 0) as total_points',
              'COUNT(DISTINCT users.id) as student_count',
              'CASE 
                WHEN COUNT(DISTINCT users.id) > 0 
                THEN COALESCE(SUM(question_attempts.score), 0)::float / COUNT(DISTINCT users.id) 
                ELSE 0 
              END as average_points_per_student'
            )
            .order('total_points DESC')
    
    query = query.limit(limit) if limit
    query
  end
  
   # ============================================================================
  # ANALYTICS CORE METHODS (can also be in the concern)
  # ============================================================================
  
  

  

  def quiz_performance_metrics(period = 30.days)
    {
      total_attempts_vs_completed: quiz_attempts_vs_completed(period),
      average_attempts_per_quiz: average_attempts_per_quiz(period),
      time_to_complete_stats: time_to_complete_statistics(period),
      retry_patterns: quiz_retry_patterns(period),
      abandonment_analysis: quiz_abandonment_analysis(period),
      difficulty_analysis: quiz_difficulty_analysis(period),
      completion_funnel: quiz_completion_funnel(period)
    }
  end

  def subject_performance_breakdown(period = 30.days)
    {
      average_scores_by_subject: average_scores_by_subject(period),
      subject_popularity: subject_popularity_rankings(period),
      subject_completion_rates: subject_completion_rates(period),
      subject_difficulty_rankings: subject_difficulty_rankings(period),
      subject_performance_trends: subject_performance_trends(period),
      learning_path_progression: learning_path_progression(period)
    }
  end

  def student_performance_distribution(period = 30.days)
    {
      score_distribution: score_grade_distribution(period),
      top_performers: top_performing_students(period),
      students_needing_support: students_needing_support(period),
      performance_improvement_trends: performance_improvement_trends(period),
      consistency_analysis: student_consistency_analysis(period),
      achievement_levels: student_achievement_levels(period)
    }
  end

  def temporal_analytics(period = 30.days)
    {
      monthly_trends: monthly_performance_trends(period),
      seasonal_patterns: seasonal_learning_patterns(period),
      weekly_patterns: weekly_activity_patterns(period),
      peak_periods: peak_activity_periods(period),
      learning_velocity: learning_velocity_trends(period)
    }
  end

  def comparative_analytics(period = 30.days)
    {
      platform_comparison: vs_platform_average(period),
      peer_comparison: vs_peer_institutions(period),
      historical_comparison: vs_historical_performance(period),
      goal_achievement: goal_achievement_tracking(period),
      ranking_data: current_ranking_data(period)
    }
  end

  private

  # ============================================================================
  # EXECUTIVE SUMMARY HELPER METHODS
  # ============================================================================

  def active_students_count(period)
    users.where(role: :student, institution_id: id).joins(:quiz_sessions)
            .where(quiz_sessions: { started_at: period_range(period) })
            .distinct
            .count
  end
  
  def overall_quiz_completion_rate(period)
    sessions = quiz_sessions_in_period(period)
    return 0 if sessions.empty?
    
    completed_count = sessions.where.not(completed_at: nil).count
    (completed_count.to_f / sessions.count * 100).round(1)
  end

  

  def total_learning_hours(period)
    # Calculate based on session duration
    sessions = quiz_sessions_in_period(period).where.not(completed_at: nil)
    
    total_minutes = sessions.sum do |session|
      if session.started_at && session.completed_at
        ((session.completed_at - session.started_at) / 1.minute).round
      else
        0
      end
    end
    
    (total_minutes / 60.0).round(1)
  end

  def calculate_growth_rate(period)
    current_period = period_range(period)
    previous_period = calculate_previous_period(period)
    
    current_active = active_students_count(period)
    previous_active = users.where(role: :student, institution_id: id).joins(:quiz_sessions)
                             .where(quiz_sessions: { started_at: previous_period })
                             .distinct
                             .count
    
    return 0 if previous_active == 0
    ((current_active - previous_active).to_f / previous_active * 100).round(1)
  end

  def completed_quizzes_count(period)
    quiz_sessions_in_period(period).where.not(completed_at: nil).count
  end

  def platform_engagement_score(period)
    # Calculate a composite engagement score (0-100)
    completion_rate = overall_quiz_completion_rate(period)
    avg_score = institution_average_score(period)
    retention_rate = student_retention_rate(period)
    
    # Weighted average
    ((completion_rate * 0.4) + (avg_score * 0.4) + (retention_rate * 0.2)).round(1)
  end

  # ============================================================================
  # ENGAGEMENT ANALYTICS HELPER METHODS  
  # ============================================================================

  def student_login_frequency(period)
    # This would require tracking login times - placeholder for now
    # You might need to add a login tracking system
    {
      daily_average: 1.2,
      weekly_average: 8.4,
      most_active_day: 'Tuesday'
    }
  end

  def daily_active_users(period)
    period_range(period).group_by(&:to_date).transform_values do |dates|
      students.joins(:quiz_sessions)
              .where(quiz_sessions: { started_at: dates.first.beginning_of_day..dates.first.end_of_day })
              .distinct
              .count
    end
  end

  def weekly_active_users(period)
    # Calculate weekly active users
    weeks = period_range(period).group_by { |date| date.beginning_of_week }
    
    weeks.transform_values do |week_dates|
      students.joins(:quiz_sessions)
              .where(quiz_sessions: { started_at: week_dates.first..week_dates.last })
              .distinct
              .count
    end
  end

  def student_retention_rate(period)
    # Students who were active in both current and previous period
    current_students = users.where(role: :student, institution_id: id).joins(:quiz_sessions)
                              .where(quiz_sessions: { started_at: period_range(period) })
                              .distinct
                              
    previous_period = calculate_previous_period(period)
    previous_students = users.where(role: :student, institution_id: id).joins(:quiz_sessions)
                               .where(quiz_sessions: { started_at: previous_period })
                               .distinct

    return 0 if previous_students.count == 0
    
    retained = current_students.where(id: previous_students.ids).count
    (retained.to_f / previous_students.count * 100).round(1)
  end

  def inactive_students_count(period)
    # Students with no activity in the period
    total_students = students.count
    active_students = active_students_count(period)
    total_students - active_students
  end

  # ============================================================================
  # QUIZ PERFORMANCE HELPER METHODS
  # ============================================================================

  def quiz_attempts_vs_completed(period)
    sessions = quiz_sessions_in_period(period)
    {
      total_attempts: sessions.count,
      completed: sessions.where.not(completed_at: nil).count,
      in_progress: sessions.where(completed_at: nil).count
    }
  end

  def average_attempts_per_quiz(period)
    sessions = quiz_sessions_in_period(period)
    unique_quizzes = sessions.group(:subject_id, :topic_id).count.keys.length
    
    return 0 if unique_quizzes == 0
    (sessions.count.to_f / unique_quizzes).round(1)
  end

  def time_to_complete_statistics(period)
    completed_sessions = quiz_sessions_in_period(period)
                        .where.not(completed_at: nil, started_at: nil)
    
    durations = completed_sessions.map do |session|
      (session.completed_at - session.started_at) / 1.minute
    end.compact

    return { average: 0, median: 0, min: 0, max: 0 } if durations.empty?

    {
      average: (durations.sum / durations.length).round(1),
      median: durations.sort[durations.length / 2].round(1),
      min: durations.min.round(1),
      max: durations.max.round(1)
    }
  end

  # ============================================================================
  # SUBJECT PERFORMANCE HELPER METHODS
  # ============================================================================

  def average_scores_by_subject(period)
    Subject.joins(quiz_sessions: :user)
           .where(users: { institution_id: id })
           .where(quiz_sessions: { completed_at: period_range(period) })
           .where.not(quiz_sessions: { total_score: nil, max_score: nil })
           .where('quiz_sessions.max_score > 0')
           .group('subjects.name')
           .average('quiz_sessions.total_score::float / quiz_sessions.max_score * 100')
           .transform_values { |score| score.round(1) }
  end

  def subject_popularity_rankings(period)
    Subject.joins(quiz_sessions: :user)
           .where(users: { institution_id: id })
           .where(quiz_sessions: { started_at: period_range(period) })
           .group('subjects.name')
           .count('quiz_sessions.id')
           .sort_by { |_, count| -count }
           .to_h
  end

  def subject_completion_rates(period)
    Subject.joins(quiz_sessions: :user)
           .where(users: { institution_id: id })
           .where(quiz_sessions: { started_at: period_range(period) })
           .group('subjects.name')
           .group('CASE WHEN quiz_sessions.completed_at IS NOT NULL THEN \'completed\' ELSE \'started\' END')
           .count
           .each_with_object({}) do |((subject, status), count), result|
      result[subject] ||= { completed: 0, started: 0 }
      result[subject][status.to_sym] = count
    end
           .transform_values do |counts|
      total = counts[:completed] + counts[:started]
      total > 0 ? (counts[:completed].to_f / total * 100).round(1) : 0
    end
  end

  # ============================================================================
  # UTILITY METHODS
  # ============================================================================



  def quiz_sessions_in_period(period)
    QuizSession.joins(:user)
           .where(users: { institution_id: id }).where(started_at: period_range(period))
  end

  
  
end