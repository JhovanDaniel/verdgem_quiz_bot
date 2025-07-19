class LevelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_level, only: [:show, :start_quiz, :edit, :update]
  before_action :set_world, only: [:index, :new, :create, :edit]
  
  def index
  
  end
  
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
  
  def new
    @level = Level.new
  end
  
  def create
    @level = Level.new(level_params)
    
    if @level.save
      redirect_to world_levels_path(@world), notice: 'Level was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    
  end
  
  def update
    if @level.update(level_params)
      redirect_to world_levels_path, notice: 'Level was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def start_quiz
    unless @level.unlocked_for?(current_user)
      redirect_to world_path(@level.world), alert: "Level not unlocked!"
      return
    end
    
    redirect_to start_quiz_path(
      level_id: @level.id,
      subject_id: @level.world.subject_id,
      topic_id: @level.topic_id,
      sub_topic_id: @level.sub_topic_id,
      difficulty: @level.difficulty,
      question_type: @level.question_type,
      count: @level.question_count
    )
  end
  
  private
  
  def set_level
    @level = Level.find(params[:id])
  end
  
  def set_world
    @world = World.find(params[:world_id])
  end
  
  def level_params
    params.require(:level).permit(:name, :description, :level_icon, :difficulty, :position, :question_type, 
    :question_count, :passing_score_percentage, :active, :world_id, :sub_topic_id, :prerequisite_level_id)
  end
end
