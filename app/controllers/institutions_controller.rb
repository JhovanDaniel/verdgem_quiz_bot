class InstitutionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_institution, only: [:edit, :update, :show, :analytics_dashboard, :executive_summary, 
    :engagement_analytics, :quiz_performance,:subject_breakdown, :student_distribution,
    :temporal_analysis, :comparative_analysis, :export_report]

  def index
    @institutions = Institution.all
  end
  
  def show
    @last_quiz_activity = QuizSession.joins(:user)
      .where(users: { institution_id: @institution.id })
      .where.not(completed_at: nil)
      .order(completed_at: :desc)
      .first
      
    
    @recent_quiz_sessions = QuizSession.joins(:user)
      .where(users: { institution_id: @institution.id })
      .where.not(completed_at: nil)
      .order(completed_at: :desc).limit(5)
  end
  
  def redirect_to_institution
    redirect_to institution_path(current_user.institution_id)
  end
  
  def new
    @institution = Institution.new
  end
  
  def create 
    @institution = Institution.new(institution_params)
    
    if @institution.save
      redirect_to institution_path(@institution), notice: 'Institution was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    
  end
  
  def update
    if @institution.update(institution_params)
      redirect_to institution_path(@institution), notice: 'Institution was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def analytics_dashboard
    # Main dashboard page - loads the HTML structure
    @initial_data = executive_summary_data
    respond_to do |format|
      format.html # renders analytics_dashboard.html.erb
    end
  end

  def executive_summary
    respond_to do |format|
      format.json do
        render json: {
          kpis: @institution.executive_summary(@time_period),
          charts: {
            performance_trend: performance_trend_data,
            activity_distribution: activity_distribution_data,
            growth_metrics: growth_metrics_data
          }
        }
      end
    end
  end

  def engagement_analytics
    analytics = @institution.student_engagement_analytics(@time_period)
    
    respond_to do |format|
      format.json do
        render json: {
          metrics: analytics,
          charts: {
            daily_active_users: daily_active_users_chart_data,
            peak_usage_heatmap: peak_usage_heatmap_data,
            retention_cohort: retention_cohort_data,
            engagement_funnel: engagement_funnel_data
          },
          tables: {
            engagement_breakdown: engagement_breakdown_table_data
          }
        }
      end
    end
  end

  def quiz_performance
    performance = @institution.quiz_performance_metrics(@time_period)
    
    respond_to do |format|
      format.json do
        render json: {
          metrics: performance,
          charts: {
            completion_funnel: quiz_completion_funnel_data,
            difficulty_analysis: quiz_difficulty_chart_data,
            retry_patterns: retry_patterns_chart_data,
            abandonment_points: abandonment_analysis_data
          },
          insights: {
            top_performing_quizzes: top_performing_quizzes,
            most_challenging_quizzes: most_challenging_quizzes,
            improvement_opportunities: improvement_opportunities
          }
        }
      end
    end
  end

  def subject_breakdown
    breakdown = @institution.subject_performance_breakdown(@time_period)
    
    respond_to do |format|
      format.json do
        render json: {
          metrics: breakdown,
          charts: {
            subject_performance_comparison: subject_performance_chart_data,
            subject_popularity: subject_popularity_chart_data,
            difficulty_by_subject: subject_difficulty_chart_data,
            learning_paths: learning_path_progression_data
          },
          recommendations: subject_recommendations
        }
      end
    end
  end

  def student_distribution
    distribution = @institution.student_performance_distribution(@time_period)
    
    respond_to do |format|
      format.json do
        render json: {
          metrics: distribution,
          charts: {
            grade_distribution: grade_distribution_chart_data,
            performance_categories: performance_categories_chart_data,
            improvement_trends: improvement_trends_chart_data,
            consistency_analysis: consistency_analysis_chart_data
          },
          student_lists: {
            top_performers: top_performers_list,
            needs_support: students_needing_support_list,
            most_improved: most_improved_students_list
          }
        }
      end
    end
  end

  def temporal_analysis
    temporal = @institution.temporal_analytics(@time_period)
    
    respond_to do |format|
      format.json do
        render json: {
          metrics: temporal,
          charts: {
            monthly_trends: monthly_trends_chart_data,
            seasonal_patterns: seasonal_patterns_chart_data,
            weekly_patterns: weekly_patterns_chart_data,
            hourly_patterns: hourly_patterns_chart_data
          },
          forecasts: {
            projected_growth: projected_growth_data,
            seasonal_forecast: seasonal_forecast_data
          }
        }
      end
    end
  end

  def comparative_analysis
    comparison = @institution.comparative_analytics(@time_period)
    
    respond_to do |format|
      format.json do
        render json: {
          metrics: comparison,
          charts: {
            platform_comparison: platform_comparison_chart_data,
            peer_comparison: peer_institutions_chart_data,
            ranking_history: ranking_history_chart_data,
            benchmark_radar: benchmark_radar_chart_data
          },
          rankings: {
            current_position: current_ranking_position,
            category_rankings: category_rankings_data,
            improvement_opportunities: ranking_improvement_opportunities
          }
        }
      end
    end
  end

  def export_report
    report_data = generate_comprehensive_report
    
    respond_to do |format|
      format.pdf do
        pdf = ReportGeneratorService.new(@institution, @time_period, @filters)
                                   .generate_pdf_report(report_data)
        send_data pdf.render, 
                  filename: "#{@institution.name.parameterize}_report_#{Date.current}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
      
      format.xlsx do
        xlsx = ReportGeneratorService.new(@institution, @time_period, @filters)
                                    .generate_excel_report(report_data)
        send_data xlsx.to_stream.read,
                  filename: "#{@institution.name.parameterize}_report_#{Date.current}.xlsx",
                  type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                  disposition: 'attachment'
      end
      
      format.json { render json: report_data }
    end
  end
  
  private
  
  def set_institution
    @institution = Institution.find(params[:id])
  end
  
  def institution_params
    params.require(:institution).permit(:name, :description, :active, :contact_email, :phone, :address,
    :institution_logo, :country)
  end
  
  def set_analytics_params
    @time_period = parse_time_period(params[:period] || '30')
    @subject_filter = params[:subject] || 'all'
    @student_group = params[:student_group] || 'all'
    @filters = { subject: @subject_filter, student_group: @student_group }
  end

  def parse_time_period(period)
    case period.to_s
    when '7' then 7.days
    when '30' then 30.days  
    when '90' then 90.days
    when '365' then 365.days
    when 'custom' then parse_custom_range
    else 30.days
    end
  end

  def parse_custom_range
    start_date = Date.parse(params[:start_date]) rescue 30.days.ago
    end_date = Date.parse(params[:end_date]) rescue Time.current
    start_date..end_date
  end

  def ensure_institution_access
    unless current_user.institution_admin? || 
           current_user.admin? || 
           current_user.institution == @institution
      redirect_to root_path, alert: 'Access denied'
    end
  end

  # ============================================================================
  # CHART DATA METHODS
  # ============================================================================

  def executive_summary_data
    @institution.executive_summary(@time_period || 30.days)
  end

  def performance_trend_data
    @institution.daily_performance_data(@time_period).map do |date, metrics|
      {
        date: date.strftime('%Y-%m-%d'),
        average_score: metrics[:average_score],
        completion_rate: metrics[:completion_rate],
        active_students: metrics[:active_students]
      }
    end
  end

  def activity_distribution_data
    engagement = @institution.student_engagement_analytics(@time_period)
    [
      { label: 'Quiz Sessions', value: engagement[:total_quiz_sessions] },
      { label: 'Study Time', value: engagement[:total_study_time] },
      { label: 'Practice Questions', value: engagement[:practice_questions] },
      { label: 'Review Sessions', value: engagement[:review_sessions] }
    ]
  end

  def growth_metrics_data
    # Compare current period vs previous period
    current_metrics = @institution.executive_summary(@time_period)
    previous_period = @time_period.is_a?(Range) ? 
                     (@time_period.begin - @time_period.size)..@time_period.begin :
                     (@time_period.ago - @time_period)..@time_period.ago
    previous_metrics = @institution.executive_summary(previous_period)

    {
      current: current_metrics,
      previous: previous_metrics,
      growth: calculate_growth_rates(current_metrics, previous_metrics)
    }
  end

  def daily_active_users_chart_data
    @institution.daily_active_users_data(@time_period).map do |date, count|
      {
        date: date.strftime('%Y-%m-%d'),
        active_users: count,
        day_of_week: date.strftime('%A')
      }
    end
  end

  def peak_usage_heatmap_data
    # Generate heatmap data for hours vs days of week
    usage_data = @institution.hourly_usage_patterns(@time_period)
    
    (0..6).map do |day|
      (0..23).map do |hour|
        {
          day: Date::DAYNAMES[day],
          hour: hour,
          activity: usage_data[day][hour] || 0
        }
      end
    end.flatten
  end

  def quiz_completion_funnel_data
    funnel_data = @institution.quiz_completion_funnel(@time_period)
    [
      { stage: 'Started', count: funnel_data[:started], percentage: 100 },
      { stage: 'In Progress', count: funnel_data[:in_progress], 
        percentage: calculate_percentage(funnel_data[:in_progress], funnel_data[:started]) },
      { stage: 'Completed', count: funnel_data[:completed], 
        percentage: calculate_percentage(funnel_data[:completed], funnel_data[:started]) },
      { stage: 'Retaken', count: funnel_data[:retaken], 
        percentage: calculate_percentage(funnel_data[:retaken], funnel_data[:started]) }
    ]
  end

  def subject_performance_chart_data
    @institution.subjects_with_performance(@time_period).map do |subject_data|
      {
        subject: subject_data[:name],
        average_score: subject_data[:average_score],
        completion_rate: subject_data[:completion_rate],
        total_attempts: subject_data[:total_attempts],
        difficulty_rating: subject_data[:difficulty_rating]
      }
    end
  end

  def grade_distribution_chart_data
    distribution = @institution.grade_distribution(@time_period)
    [
      { grade: 'A (90-100%)', count: distribution[:a], percentage: distribution[:a_percentage] },
      { grade: 'B (80-89%)', count: distribution[:b], percentage: distribution[:b_percentage] },
      { grade: 'C (70-79%)', count: distribution[:c], percentage: distribution[:c_percentage] },
      { grade: 'D (60-69%)', count: distribution[:d], percentage: distribution[:d_percentage] },
      { grade: 'F (0-59%)', count: distribution[:f], percentage: distribution[:f_percentage] }
    ]
  end

  def top_performers_list
    @institution.students
                .joins(:quiz_sessions)
                .where(quiz_sessions: { completed_at: period_range(@time_period) })
                .group('users.id')
                .order('AVG(CASE WHEN quiz_sessions.total_score IS NOT NULL AND quiz_sessions.max_score > 0 
                         THEN quiz_sessions.total_score::float / quiz_sessions.max_score * 100 
                         ELSE 0 END) DESC')
                .limit(10)
                .includes(:quiz_sessions)
                .map do |student|
      {
        name: student.name,
        average_score: student.score_percentage_from_finished_quizzes(*period_range(@time_period).minmax),
        quizzes_completed: student.quiz_sessions.where(completed_at: period_range(@time_period)).count
      }
    end
  end

  def students_needing_support_list
    @institution.students
                .joins(:quiz_sessions)
                .where(quiz_sessions: { completed_at: period_range(@time_period) })
                .group('users.id')
                .having('AVG(CASE WHEN quiz_sessions.total_score IS NOT NULL AND quiz_sessions.max_score > 0 
                         THEN quiz_sessions.total_score::float / quiz_sessions.max_score * 100 
                         ELSE 0 END) < 60')
                .order('AVG(CASE WHEN quiz_sessions.total_score IS NOT NULL AND quiz_sessions.max_score > 0 
                         THEN quiz_sessions.total_score::float / quiz_sessions.max_score * 100 
                         ELSE 0 END) ASC')
                .limit(10)
                .includes(:quiz_sessions)
                .map do |student|
      {
        name: student.name,
        average_score: student.score_percentage_from_finished_quizzes(*period_range(@time_period).minmax),
        quizzes_attempted: student.quiz_sessions.where(started_at: period_range(@time_period)).count
      }
    end
  end

  def generate_comprehensive_report
    {
      institution: @institution.as_json(only: [:id, :name, :description, :created_at]),
      report_metadata: {
        generated_at: Time.current,
        period: @time_period,
        filters: @filters,
        generated_by: current_user.name
      },
      executive_summary: @institution.executive_summary(@time_period),
      engagement_analytics: @institution.student_engagement_analytics(@time_period),
      quiz_performance: @institution.quiz_performance_metrics(@time_period),
      subject_breakdown: @institution.subject_performance_breakdown(@time_period),
      student_distribution: @institution.student_performance_distribution(@time_period),
      recommendations: generate_actionable_recommendations
    }
  end

  def generate_actionable_recommendations
    recommendations = []
    summary = @institution.executive_summary(@time_period)
    
    if summary[:overall_completion_rate] < 70
      recommendations << {
        category: 'Completion Rate',
        priority: 'High',
        issue: 'Low quiz completion rate',
        recommendation: 'Consider implementing progress tracking and reminder systems',
        potential_impact: 'Could improve completion rates by 15-20%'
      }
    end
    
    engagement = @institution.student_engagement_analytics(@time_period)
    if engagement[:retention_rate] < 60
      recommendations << {
        category: 'Student Retention',
        priority: 'High',
        issue: 'Low student retention rate',
        recommendation: 'Implement gamification and regular check-ins',
        potential_impact: 'Could improve retention by 25-30%'
      }
    end
    
    recommendations
  end

  # ============================================================================
  # HELPER METHODS
  # ============================================================================

  def calculate_percentage(numerator, denominator)
    return 0 if denominator == 0
    (numerator.to_f / denominator * 100).round(1)
  end

  def calculate_growth_rates(current, previous)
    {
      active_students: calculate_growth_rate(current[:total_active_students], previous[:total_active_students]),
      completion_rate: calculate_growth_rate(current[:overall_completion_rate], previous[:overall_completion_rate]),
      average_score: calculate_growth_rate(current[:institution_average_score], previous[:institution_average_score]),
      learning_hours: calculate_growth_rate(current[:total_learning_hours], previous[:total_learning_hours])
    }
  end

  def calculate_growth_rate(current_value, previous_value)
    return 0 if previous_value == 0 || previous_value.nil?
    ((current_value - previous_value).to_f / previous_value * 100).round(1)
  end

  def period_range(period)
    period.is_a?(Range) ? period : period.ago..Time.current
  end
  

  
end
