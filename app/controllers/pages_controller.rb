class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:home]
  
  def home
    @subjects = Subject.all
    @quiz_sessions = current_user.quiz_sessions.order(created_at: :desc).limit(10)
    @recent_attempts = current_user.question_attempts.includes(question: { topic: :subject }).order(created_at: :desc).limit(5)
    
    # Get some stats for the dashboard
    @total_questions_attempted = current_user.question_attempts.count
    @correct_answers = current_user.question_attempts
                              .joins(:question)
                              .where("question_attempts.score >= (questions.max_points * 0.7)")
                              .count
    
    # Find subject progress
    @subject_progress = {}
    Subject.all.each do |subject|
      question_count = subject.questions.count
      attempted_count = current_user.question_attempts.joins(question: { topic: :subject }).where(topics: { subject_id: subject.id }).select("DISTINCT questions.id").count
      
      if question_count > 0
        @subject_progress[subject.id] = (attempted_count.to_f / question_count * 100).round
      else
        @subject_progress[subject.id] = 0
      end
    end
    
    #Check for unfinished quizzes
    @unfinished_quiz = current_user.quiz_sessions
                                 .where(completed_at: nil)
                                 .order(created_at: :desc)
                                 .first
  end
  
  def configuration
    
  end
  
  def teacher_dashboard
  end
  
  def landing_page
  end
  
  def about
  end
  
  def our_blog
  end
  
  def faqs
  end
  
  def csec_quizzes
  end
  
  def reports
  end
end
