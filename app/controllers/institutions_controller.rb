class InstitutionsController < ApplicationController
  before_action :authenticate_user!

  def index
  end
  
  def show
  end
  
  def new
  end
  
  def create 
  end
  
  def edit
  end
  
  def update
  end
  
  private
  
  def institutions_params
    params.require(:subject).permit(:name, :description, :active, :contact_email, :phone, :address)
  end
  

  
end
