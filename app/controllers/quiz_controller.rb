class QuizController < ApplicationController
  before_action :authenticate_user!
  
  def start
    @subject = Subject.find(params[:subject_id])
    @topics = params[:topic_id].present? ? Topic.where(id: params[:topic_id]) : @subject.topics
    
    # Get questions based on selected topics and difficulty
    @questions = Question.where(topic: @topics)
                        .where(difficulty_level: params[:difficulty] || 'medium')
                        .order("RANDOM()").limit(params[:count] || 5)
    
    # Store questions in session for the quiz
    session[:quiz_questions] = @questions.pluck(:id)
    session[:current_question_index] = 0
    
    redirect_to show_quiz_path
  end
  
  def show
    # Get the current question
    question_id = session[:quiz_questions][session[:current_question_index]]
    @question = Question.find(question_id)
  end
  
  def evaluate_answer
    @question = Question.find(params[:question_id])
    student_answer = params[:answer]
    
    # Here you would integrate with Claude API
    # For now, let's just save the attempt
    attempt = current_user.question_attempts.create(
      question: @question,
      student_answer: student_answer,
      max_score: @question.max_points
    )
    
    # Move to next question or finish
    session[:current_question_index] += 1
    
    if session[:current_question_index] >= session[:quiz_questions].length
      redirect_to result_quiz_path
    else
      redirect_to show_quiz_path
    end
  end
  
  def result
    # Show quiz results
    @question_ids = session[:quiz_questions]
    @attempts = current_user.question_attempts.where(question_id: @question_ids).order(:created_at)
  end
end