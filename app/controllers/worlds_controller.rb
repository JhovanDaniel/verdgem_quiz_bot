class WorldsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_world, only: [:show, :edit, :update]
  
  def index
    @worlds = World.active
       .includes(:subject, :levels)
    
    @progress_data = build_progress_data
  end
  
  def show
    @levels = @world.levels.includes(:user_level_progresses)
    @world_progress = @world.completion_percentage_for(current_user)
    @world_status = @world.status_for(current_user)

    #@levels_with_progress = @levels.map do |level|
      #{
        #level: level,
        #status: level.status_for(current_user),
        #progress: level.progress_for(current_user),
        #attempts: level.attempts_by(current_user),
        #best_score: level.best_score_by(current_user)
      #}
    #end
  end
  
  def new
    @world = World.new
  end
  
  def create
    @world = World.new(world_params)
    
    if @world.save
      redirect_to worlds_path, notice: 'World was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  
  end
  
  def update
    if @world.update(world_params)
      redirect_to worlds_path, notice: 'World was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_world
    @world = World.find(params[:id])
  end
  
  def world_params
    params.require(:world).permit(:name, :description, :subject_id, :is_active, :world_icon)
  end
  
  def build_progress_data
    progress_data = {}
    
    World.active.includes(:levels).each do |world|
      progress_data[world.id] = {
        completion_percentage: world.completion_percentage_for(current_user),
        status: world.status_for(current_user),
        completed_levels: world.completed_levels_for(current_user),
        total_levels: world.total_levels,
      }
    end
    
    progress_data
  end
end