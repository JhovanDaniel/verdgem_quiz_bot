class QuestionsController < ApplicationController
  before_action :set_topic, only: [:new, :create]
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  
  def new
    @question = @topic.questions.build
    # Set some default values
    @question.max_points = 5
    @question.difficulty_level = 'medium'
  end
  
  def create
    @topic = Topic.find(params[:topic_id])
    @question = @topic.questions.new(question_params)
    
    # Add logic to ensure at least one correct answer for multiple choice
    if @question.multiple_choice? && question_params[:answer_options_attributes].present?
      has_correct_answer = question_params[:answer_options_attributes].values.any? { |opt| opt[:is_correct] == "1" }
      
      unless has_correct_answer
        flash[:alert] = "Multiple choice questions must have at least one correct answer"
        redirect_to new_topic_question_path(@topic)
        return
      end
    end
    
    if @question.save
      redirect_to topic_path(@topic), notice: 'Question was successfully created.'
    else
      flash[:alert] = @question.errors.full_messages.to_sentence
      redirect_to new_topic_question_path(@topic)
    end
  end
  
  def edit
    @topic = @question.topic
  end
  
  def update
    @topic = @question.topic
    
    if @question.update(question_params)
      redirect_to topic_path(@topic), notice: 'Question was successfully updated.'
    else
      flash[:alert] = @question.errors.full_messages.to_sentence
      redirect_to edit_question_path(@question)  # ← Use redirect instead of render
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
  
  def question_params
    params.require(:question).permit(:content, :model_answer, :key_concepts, :marking_criteria, 
      :max_points, :difficulty_level, :has_problem, :question_type,
      answer_options_attributes: [:id, :content, :is_correct, :position, :_destroy]
    )
  end
end