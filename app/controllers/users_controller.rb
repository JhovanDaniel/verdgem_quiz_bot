class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  
  def index
    @users = User.all
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    
    # Generate a random password if none provided
    @user.password = SecureRandom.hex(8) if @user.password.blank?
    
    if @user.save
      redirect_to users_path, notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def admin_new
    @user = User.new
  end
  
  def admin_create
    @user = User.new(user_params)
    
    # Generate a random password if none provided
    @user.password = SecureRandom.hex(8) if @user.password.blank?
    
    if @user.save
      redirect_to users_path, notice: "User was successfully created."
    else
      render :admin_new, status: :unprocessable_entity
    end
  end
  
  private
  
  def require_admin
    unless current_user.admin?
      redirect_to authenticated_root_path, alert: "You are not authorized to access this page."
    end
  end
  
  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :role, :password, :password_confirmation)
  end
end
