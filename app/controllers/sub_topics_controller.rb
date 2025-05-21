# app/controllers/sub_topics_controller.rb
class SubTopicsController < ApplicationController
  before_action :set_topic, only: [:index, :new, :create]
  before_action :set_sub_topic, only: [:show, :edit, :update, :destroy]

  def index
    @sub_topics = @topic.sub_topics.order(:name)
    
    respond_to do |format|
      format.html # Your existing HTML view
      format.json { render json: @sub_topics }
    end
  end
  
  def show
    @questions = @sub_topic.questions.order(created_at: :desc)
  end
  
  def new
    @sub_topic = @topic.sub_topics.new
  end
  
  def edit
  end
  
  def create
    @sub_topic = @topic.sub_topics.new(sub_topic_params)
    
    if @sub_topic.save
      redirect_to @sub_topic, notice: 'Sub-topic was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @sub_topic.update(sub_topic_params)
      redirect_to @sub_topic, notice: 'Sub-topic was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    topic = @sub_topic.topic
    @sub_topic.destroy
    redirect_to topic_sub_topics_path(topic), notice: 'Sub-topic was successfully destroyed.'
  end
  
  private
  
  def set_topic
    @topic = Topic.find(params[:topic_id])
  end
  
  def set_sub_topic
    @sub_topic = SubTopic.find(params[:id])
  end
  
  def authorize_admin
    redirect_to root_path, alert: 'Unauthorized access' unless current_user.admin?
  end
  
  def sub_topic_params
    params.require(:sub_topic).permit(:name, :description)
  end
end