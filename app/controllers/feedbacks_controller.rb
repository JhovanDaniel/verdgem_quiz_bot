class FeedbacksController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @quiz_session = QuizSession.find(params[:quiz_session_id])
    
    # Ensure user can only provide feedback for their own quiz sessions
    unless @quiz_session.user == current_user
      redirect_to authenticated_root_path, alert: "You can only provide feedback for your own quizzes."
      return
    end
    
    @feedback = @quiz_session.build_feedback(feedback_params)
    
    if @feedback.save
      redirect_to quiz_session_path(@quiz_session), notice: "Thank you for your feedback!"
    else
      redirect_to quiz_results_path, alert: "Couldn't save your feedback: #{@feedback.errors.full_messages.join(', ')}"
    end
  end
  
  private
  
  def feedback_params
    params.require(:feedback).permit(:rating, :comment)
  end
end