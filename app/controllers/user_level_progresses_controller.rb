class UserLevelProgressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:index, :show]
  before_action :authorize_access, only: [:index, :show]
  
  def index
    @worlds = World.active.includes(:levels, levels: :user_level_progresses)
  end
  
  def show
    @progress = UserLevelProgress.find(params[:id])
    @level = @progress.level
    @world = @level.world
    
    # Get detailed quiz history for this level
    @quiz_history = @user.quiz_sessions
                         .where(level: @level)
                         .includes(:question_attempts)
                         .order(created_at: :desc)
  end
  
  private
  
  def set_user
    @user = params[:user_id] ? User.find(params[:user_id]) : current_user
  end
  
  def authorize_access
    unless @user == current_user || current_user.admin? || current_user.teacher?
      redirect_to authenticated_root_path, alert: "Access denied."
    end
  end
  
end
