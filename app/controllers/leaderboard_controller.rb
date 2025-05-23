class LeaderboardController < ApplicationController
  #before_action :authenticate_user!
  
  def index
    # Set date range for current month
    @current_month = params[:month] ? Date.parse(params[:month]) : Date.today
    @start_date = @current_month.beginning_of_month
    @end_date = @current_month.end_of_month
    
    # Get only completed quiz sessions for the date range
    completed_quiz_sessions = QuizSession.where(completed_at: @start_date..@end_date)
    
    # Get question attempts from only completed quizzes
    completed_quiz_attempts = QuestionAttempt.where(quiz_session_id: completed_quiz_sessions.pluck(:id))
    
    # Get top users by total score for the current month (minimum 10 questions attempted)
    @top_by_score = User.where(role: 'student')
                .select { |user| user.completed_questions_from_finished_quizzes_count(@start_date, @end_date) >= 10 }
                .sort_by { |user| -user.total_score_from_finished_quizzes(@start_date, @end_date) }
                .take(10)
    
    # Get top users by percentage for the current month (minimum 10 questions attempted)
    @top_by_percentage = User.where(role: 'student')
                             .select { |user| user.completed_questions_from_finished_quizzes_count(@start_date, @end_date) >= 10 }
                             .sort_by { |user| -user.score_percentage_from_finished_quizzes(@start_date, @end_date) }
                             .take(10)
    
    # Get current user's rank for each category
    if current_user
      if current_user.completed_questions_count(@start_date, @end_date) >= 10
        @score_rank = User.joins(:question_attempts)
                 .where(role: 'student')
                 .where(question_attempts: { created_at: @start_date..@end_date })
                 .group('users.id')
                 .having('COUNT(question_attempts.id) >= 10')
                 .select('users.*, SUM(question_attempts.score) as total_points')
                 .order(Arel.sql('SUM(question_attempts.score) DESC'))
                 .pluck(:id)
                 .index(current_user.id)
                          
        @score_rank = @score_rank ? @score_rank + 1 : nil
        
        @percentage_rank = User.where(role: 'student')
                               .select { |user| user.completed_questions_count(@start_date, @end_date) >= 10 }
                               .sort_by { |user| -user.score_percentage(@start_date, @end_date) }
                               .map(&:id)
                               .index(current_user.id)
                               
        @percentage_rank = @percentage_rank ? @percentage_rank + 1 : nil
      end
    end
  end
end
