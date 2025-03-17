class SubjectsController < ApplicationController
  def index
    @subjects = Subject.all
  end
  
  def new
    @subject = Subject.new
  end
  
  def create
    @subject = Subject.new(subject_params)
    
    if @subject.save
      redirect_to subjects_path, notice: "Subject was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @subject = Subject.find(params[:id])
    @topics = @subject.topics
  end
  
  private

  def subject_params
    params.require(:subject).permit(:name, :description, :syllabus_outline)
  end
end