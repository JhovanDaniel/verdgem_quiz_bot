class InstitutionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_institution, only: [:edit, :update, :show]

  def index
    @institutions = Institution.all
  end
  
  def show
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
    params.require(:institution).permit(:name, :description, :active, :contact_email, :phone, :address)
  end
  

  
end
