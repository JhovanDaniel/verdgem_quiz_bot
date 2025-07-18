class WorldsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_world, only: [:show]
  
  def index
    @worlds = World.active
       .includes(:subject, :levels)
       .ordered
    
    @progress_data = build_progress_data
  end
  
  def show
    @levels = @world.levels.includes(:user_world_progresses)
    @world_progress = @world.completion_percentage_for(current_user)
    @world_status = @world.status_for(current_user)
    @next_level = @world.next_level_for(current_user)
    
    @levels_with_progress = @levels.map do |level|
      {
        level: level,
        status: level.status_for(current_user),
        progress: level.progress_for(current_user),
        attempts: level.attempts_by(current_user),
        best_score: level.best_score_by(current_user)
      }
    end
  end
  
  def new
    
  end
  
  def create
    
  end
  
  private
  
  def set_world
    @world = World.find(params[:id])
  end
  
  def build_progress_data
    progress_data = {}
    
    World.active.includes(:levels).each do |world|
      progress_data[world.id] = {
        completion_percentage: world.completion_percentage_for(current_user),
        status: world.status_for(current_user),
        next_level: world.next_level_for(current_user)&.name,
        completed_levels: world.completed_levels_for(current_user),
        total_levels: world.total_levels,
        unlocked_levels: world.unlocked_levels_for(current_user)
      }
    end
    
    progress_data
  end
end