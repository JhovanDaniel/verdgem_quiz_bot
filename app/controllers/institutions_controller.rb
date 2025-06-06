class InstitutionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_institution, only: [:edit, :update, :show]

  def index
    @institutions = Institution.all
  end
  
  def show
    @last_quiz_activity = QuizSession.joins(:user)
      .where(users: { institution_id: @institution.id })
      .where.not(completed_at: nil)
      .order(completed_at: :desc)
      .first
      
    
    @recent_quiz_sessions = QuizSession.joins(:user)
      .where(users: { institution_id: @institution.id })
      .where.not(completed_at: nil)
      .order(completed_at: :desc).limit(5)
      
    total_quiz_sessions = QuizSession.joins(:user)
      .where(users: { 
        institution_id: @institution.id, 
        role: User.roles[:student] 
      }).count
  
    total_students = @institution.users.where(role: :student).count
  
    @average_quiz_sessions = total_students > 0 ? (total_quiz_sessions.to_f / total_students).round(0) : 0
    
    @average_score = QuizSession.joins(:user)
      .where(users: { 
       institution_id: @institution.id, 
       role: User.roles[:student] 
      })
      .where.not(completed_at: nil, total_score: nil, max_score: nil)
      .where('max_score > 0')
      .average('(total_score::float / max_score::float) * 100')
      &.round(1) || 0
  end
  
  def new
    @institution = Institution.new
  end
  
  def create 
    @institution = Institution.new(institution_params)
    
    if @institution.save
      redirect_to institution_path(@institution), notice: 'Institution was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    
  end
  
  def update
    if @institution.update(institution_params)
      redirect_to institution_path(@institution), notice: 'Institution was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_institution
    @institution = Institution.find(params[:id])
  end
  
  def institution_params
    params.require(:institution).permit(:name, :description, :active, :contact_email, :phone, :address,
    :institution_logo)
  end
  

  
end
