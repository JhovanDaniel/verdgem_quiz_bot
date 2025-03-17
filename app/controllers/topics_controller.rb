class TopicsController < ApplicationController
  def index
    @subject = Subject.find(params[:subject_id])
    @topics = @subject.topics
  end

  def show
    @topic = Topic.find(params[:id])
    @questions = @topic.questions
  end
end