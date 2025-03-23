class QuizController < ApplicationController
  before_action :authenticate_user!
  
  def quiz_select
    @subjects = Subject.all
  end
  
  def start
    @subject = Subject.find(params[:subject_id])
    @topic = Topic.find(params[:topic_id]) if params[:topic_id].present?
    
    if current_user.quiz_limit_reached?
      redirect_to authenticated_root_path, alert: "You've reached your maximum quiz attempts. Please upgrade your account for unlimited quizzes."
      return
    end
    
    # Get questions based on filters
    questions_scope = Question.joins(:topic)
    
    # Filter by subject
    questions_scope = questions_scope.where(topics: { subject_id: @subject.id })
    
    # Filter by topic if provided
    questions_scope = questions_scope.where(topic_id: @topic.id) if @topic.present?
    
    # Get the requested number of questions
    question_count = params[:count].present? ? params[:count].to_i : 5
    
    # Handle different difficulty options
    case params[:difficulty]
    when "mixed"
      # Create a mixed distribution of questions
      @questions = []
      
      # Get some easy questions (30%)
      easy_count = (question_count * 0.3).ceil
      @questions += questions_scope.where(difficulty_level: "easy")
                                   .order("RANDOM()")
                                   .limit(easy_count)
      
      # Get some medium questions (40%)
      medium_count = (question_count * 0.4).ceil
      @questions += questions_scope.where(difficulty_level: "medium")
                                   .order("RANDOM()")
                                   .limit(medium_count) 
                                   
      # Get some medium questions (20%)
      hard_count = (question_count * 0.2).ceil
      @questions += questions_scope.where(difficulty_level: "hard")
                                   .order("RANDOM()")
                                   .limit(hard_count)
      
      # Get some very hard questions (10%)
      very_hard_count = question_count - @questions.length
      @questions += questions_scope.where(difficulty_level: "very_hard")
                                   .order("RANDOM()")
                                   .limit(very_hard_count)
      
      # If we don't have enough questions of a certain difficulty, fill in with others
      if @questions.length < question_count
        remaining = question_count - @questions.length
        existing_ids = @questions.map(&:id)
        
        @questions += questions_scope.where.not(id: existing_ids)
                                     .order("RANDOM()")
                                     .limit(remaining)
      end
      
      # Shuffle the questions to mix the difficulties
      #@questions = @questions.shuffle
      
      #Order questions by difficulty
      @questions = @questions.sort_by do |question|
        case question.difficulty_level
        when "easy" then 1
        when "medium" then 2
        when "hard" then 3
        when "very_hard" then 4
        else 0
        end
      end
      
    else
      # Filter by difficulty if provided (easy, medium, hard)
      questions_scope = questions_scope.where(difficulty_level: params[:difficulty]) if params[:difficulty].present?
      
      # Select random questions up to the requested count
      @questions = questions_scope.order("RANDOM()").limit(question_count)
    end
    
    # If there are no questions matching the criteria
    if @questions.empty?
      redirect_to dashboard_path, alert: "No questions available for the selected criteria. Please try different options."
      return
    end
    
    current_user.increment_quiz_attempts!
    
    # Create a new quiz session
    @quiz_session = current_user.quiz_sessions.create(
      subject: @subject,
      topic: @topic,
      started_at: Time.current,
      max_score: @questions.sum(&:max_points),
      question_count: @questions.length 
    )
    
    # Store quiz data in session
    session[:quiz] = {
      quiz_session_id: @quiz_session.id,
      question_ids: @questions.map(&:id),
      current_index: 0
    }
    
    # Redirect to the first question
    redirect_to quiz_question_path
  end
  
  def question
    # Load the current question from session
    return redirect_to authenticated_root_path, alert: "No active quiz found." unless session[:quiz].present?
    
    current_index = session[:quiz]["current_index"]
    question_ids = session[:quiz]["question_ids"]
    
    # If we've gone beyond the available questions, go to results
    if current_index >= question_ids.length
      redirect_to quiz_results_path
      return
    end
    
    @question = Question.find(question_ids[current_index])
    @question_number = current_index + 1
    @total_questions = question_ids.length
    
    # Get the quiz session
    @quiz_session = QuizSession.find(session[:quiz]["quiz_session_id"])
  end
  
  def submit
    return redirect_to authenticated_root_path, alert: "No active quiz found." unless session[:quiz].present?
    
    current_index = session[:quiz]["current_index"]
    question_ids = session[:quiz]["question_ids"]
    quiz_session_id = session[:quiz]["quiz_session_id"]
    @question = Question.find(question_ids[current_index])
    
    # Save the user's answer with the quiz session reference
    @attempt = current_user.question_attempts.create(
      question: @question,
      student_answer: params[:answer],
      quiz_session_id: quiz_session_id  # Add this line
    )
    
    # Evaluate the answer using Claude
    if current_user
      begin
        # Show loading state
        @attempt.update(evaluation_status: "processing")
        
        # Call Claude API
        claude_service = ClaudeService.new
        evaluation = claude_service.evaluate_answer(@question, params[:answer])
        
        if evaluation[:success]
          @attempt.update(
            score: evaluation[:score],
            feedback: evaluation[:feedback],
            evaluation_status: "completed"
          )
        else
          @attempt.update(
            evaluation_status: "error",
            evaluation_error: evaluation[:error]
          )
        end
      rescue => e
        Rails.logger.error("Evaluation error: #{e.message}")
        @attempt.update(evaluation_status: "error", evaluation_error: e.message)
      end
    else
      # For non-premium users, mark for manual review or limited AI feedback
      @attempt.update(evaluation_status: "pending")
    end
    
    # Move to the next question
    session[:quiz]["current_index"] = current_index + 1
    
    # If it was the last question, go to results, otherwise next question
    if session[:quiz]["current_index"] >= question_ids.length
      redirect_to quiz_results_path
    else
      redirect_to quiz_question_path
    end
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
      student_answer: student_answer
    )
    
    # Move to next question or finish
    session[:current_question_index] += 1
    
    if session[:current_question_index] >= session[:quiz_questions].length
      redirect_to quiz_results_path
    else
      redirect_to show_quiz_path
    end
  end
  
  def results
    return redirect_to authenticated_root_path, alert: "No completed quiz found." unless session[:quiz].present?
    
    # Get the quiz session
    quiz_session_id = session[:quiz]["quiz_session_id"]
    @quiz_session = QuizSession.find(quiz_session_id)
    
    @question_ids = session[:quiz]["question_ids"]
    @questions = Question.where(id: @question_ids)
    @attempts = current_user.question_attempts
                            .where(quiz_session_id: quiz_session_id)
                            .order(:created_at)
                            .includes(:question)
    
    # Calculate quiz statistics
    @total_points = @questions.sum(:max_points)
    @earned_points = @attempts.sum(:score) || 0 # Handle nil values
    
    # Update the quiz session with final results if not already completed
    unless @quiz_session.completed?
      @quiz_session.update(
        completed_at: Time.current,
        total_score: @earned_points,
        max_score: @total_points
      )
    end
    
    # We'll keep the session data for now, but you might want to clear it
    # when the user starts a new quiz or after some time
  end
  
  def history
    @quiz_sessions = current_user.quiz_sessions
                                .order(created_at: :desc)
                                .includes(:subject, :topic)
                                .paginate(page: params[:page], per_page: 10)
  end
  
  def show_session
    @quiz_session = QuizSession.find(params[:id])
    
    # Ensure users can only see their own quiz sessions
    unless @quiz_session.user == current_user || current_user.admin?
      redirect_to authenticated_root_path, alert: "You are not authorized to view this quiz session."
      return
    end
    
    @attempts = @quiz_session.question_attempts
                           .includes(:question)
                           .order(:created_at)
  end
  
  def resume
    @quiz_session = current_user.quiz_sessions.find(params[:id])
    
    # Only allow resuming incomplete quizzes
    unless @quiz_session.completed_at.nil?
      redirect_to authenticated_root_path, alert: "This quiz has already been completed."
      return
    end
    
    # Get the questions from this session
    question_ids = @quiz_session.question_attempts.pluck(:question_id)
    
    # Find the next unanswered question
    answered_question_ids = @quiz_session.question_attempts.pluck(:question_id)
    all_question_ids = Question.where(topic_id: @quiz_session.topic_id).pluck(:id)
    
    # If no specific topic was chosen, get all questions from the subject
    if all_question_ids.empty? && @quiz_session.subject.present?
      all_question_ids = Question.joins(:topic)
                                 .where(topics: { subject_id: @quiz_session.subject_id })
                                 .pluck(:id)
    end
    
    # Find the current position
    remaining_ids = all_question_ids - answered_question_ids
    current_index = answered_question_ids.length
    
    # Store quiz data in session
    session[:quiz] = {
      quiz_session_id: @quiz_session.id,
      question_ids: all_question_ids,
      current_index: current_index
    }
    
    # Redirect to current question or results if all questions answered
    if current_index >= all_question_ids.length
      redirect_to quiz_results_path
    else
      redirect_to quiz_question_path
    end
  end
end