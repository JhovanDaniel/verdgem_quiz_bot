class QuestionsController < ApplicationController
  before_action :set_topic, only: [:new, :create]
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  
  def new
    @question = @topic.questions.build
    @question.difficulty_level = 'medium'
  end
  
  def create
    @topic = Topic.find(params[:topic_id])
    @question = @topic.questions.new(question_params)
    
    if @question.multiple_choice?
      @question.difficulty_level = :easy
    else
      @question.answer_options.clear
    end
    
    set_max_points_based_on_difficulty(@question)
    
    if @question.save
      redirect_to topic_path(@topic), notice: 'Question was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @topic = @question.topic
  end
  
  def update
    @topic = @question.topic
    
    @question.assign_attributes(question_params)
    
    if @question.multiple_choice?
      @question.difficulty_level = :easy
    else
      @question.answer_options.clear
    end
    
    set_max_points_based_on_difficulty(@question)
    
    if @question.save
      redirect_to topic_path(@topic), notice: 'Question was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    
  end

  private
  
  def set_topic
    @topic = Topic.find(params[:topic_id])
  end
  
  def set_question
    @question = Question.find(params[:id])
  end
  
  def set_max_points_based_on_difficulty(question)
    # Use string comparison since enum might be returning strings
    difficulty = question.difficulty_level.to_s
    
    case difficulty
    when 'easy'
      question.max_points = 1
    when 'medium'
      question.max_points = 3
    when 'hard'
      question.max_points = 5
    end
    
    # Debug output to see what's happening
    Rails.logger.debug "Difficulty: #{difficulty}, Max Points: #{question.max_points}"
  end
  
  def question_params
    params.require(:question).permit(:content, :model_answer, :key_concepts, :marking_criteria, 
      :max_points, :difficulty_level, :has_problem, :question_type,
      answer_options_attributes: [:id, :content, :is_correct, :position, :_destroy]
    )
  end
end