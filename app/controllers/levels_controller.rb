class LevelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_level, only: [:show, :start_quiz]
  
  def show
    @world = @level.world
    @status = @level.status_for(current_user)
    
    if @status == :locked
      redirect_to world_path(@world), alert: "Complete prerequisite levels first!"
      return
    end
    
    @progress = @level.progress_for(current_user)
    @recent_attempts = @level.quiz_sessions
                             .where(user: current_user)
                             .order(created_at: :desc)
                             .limit(3)
                             .includes(:question_attempts)
  end
  
  def start_quiz
    unless @level.unlocked_for?(current_user)
      redirect_to world_path(@level.world), alert: "Level not unlocked!"
      return
    end
    
    if current_user.quiz_limit_reached?
      redirect_to authenticated_root_path, alert: "Quiz limit reached!"
      return
    end
    
    # Generate questions for this level
    @questions = @level.start_quiz_for(current_user)
    
    if @questions.empty?
      redirect_to level_path(@level), alert: "No questions available for this level."
      return
    end
    
    current_user.increment_quiz_attempts!
    
    # Create quiz session using existing logic
    @quiz_session = current_user.quiz_sessions.create!(
      subject: @level.world.subject,
      topic: @level.topic,
      sub_topic: @level.sub_topic,
      level: @level,
      started_at: Time.current,
      max_score: @questions.sum(&:max_points),
      question_count: @questions.length,
      question_ids: @questions.map(&:id)
    )
    
    # Store quiz data in session (same as existing)
    session[:quiz] = {
      quiz_session_id: @quiz_session.id,
      current_index: 0
    }
    
    # Redirect to existing quiz flow
    redirect_to quiz_question_path
  end
  
  private
  
  def set_level
    @level = Level.find(params[:id])
  end
end
