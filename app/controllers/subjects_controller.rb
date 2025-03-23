class SubjectsController < ApplicationController
  before_action :set_subject, only: [:edit, :update]
  before_action :check_edit_permissions, only: [:edit, :update]
  
  def index
    @subjects = Subject.all
  end
  
  def new
    @subject = Subject.new
  end
  
  def create
    @subject = Subject.new(subject_params)
    @subject.created_by = current_user
    
    if @subject.save
      redirect_to subject_path(@subject), notice: "Subject was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @subject = Subject.find(params[:id])
    @topics = @subject.topics
  end
  
  def edit
    
  end
  
  def update
    if @subject.update(subject_params)
      redirect_to subject_path(@subject), notice: 'Subject was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_subject
    @subject = Subject.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name, :description, :syllabus_outline)
  end
  
  def check_edit_permissions
    @subject = Subject.find(params[:id])
    unless current_user.admin? || @subject.created_by == current_user
      redirect_to subjects_path, alert: "You don't have permission to modify this subject."
    end
  end
end