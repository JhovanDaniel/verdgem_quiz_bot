class TopicsController < ApplicationController
  before_action :set_subject, only: [:index, :new, :create]
  before_action :set_topic, only: [:show, :edit, :update]
  
  def index
    @subject = Subject.find(params[:subject_id])
    @topics = @subject.topics
  end
  
  def new
    @topic = @subject.topics.build
  end
  
  def create
    @topic = @subject.topics.build(topic_params)
    
    if @topic.save
      redirect_to subject_path(@subject), notice: "Topic was successfully created."
    else
      render :new
    end
  end
  
  def edit
    
  end
  
  def update
    if @topic.update(topic_params)
      redirect_to subject_path(@topic.subject), notice: 'Topic was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @topic = Topic.find(params[:id])
    @questions = @topic.questions.order(created_at: :desc)
  end
  
   private
  
  def set_subject
    @subject = Subject.find(params[:subject_id])
  end
  
  def set_topic
    @topic = Topic.find(params[:id])
  end
  
  def topic_params
    params.require(:topic).permit(:name, :description)
  end
end