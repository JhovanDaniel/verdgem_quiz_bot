class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, except: [:show, :user_edit, :user_update, :reset_progress, :social]
  
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
  
  def user_new
    @user = User.new
  end
  
  def user_create
    @user = User.new(user_params)
    
    # Generate a random password if none provided
    @user.password = SecureRandom.hex(8) if @user.password.blank?
    
    if @user.save
      if @user.institution_admin?
        UserMailer.institution_welcome_email(@user).deliver_later
      elsif @user.student?
        UserMailer.welcome_email(@user).deliver_later
      end
      redirect_to users_path, notice: "User was successfully created."
    else
      render :user_new, status: :unprocessable_entity
    end
  end
  
  def user_edit
    @user = User.find(params[:id])
    @include_password = true
  end
  
  def user_update
    @user = User.find(params[:id])
    
    if @user.update_with_password(user_params)
      redirect_to user_path(@user), notice: "User was successfully updated."
    else
      render :user_edit, status: :unprocessable_entity
    end
  end
  
  def show
    @user = User.find(params[:id])
    
    # Security check: only admins can view any user profile
    # Regular users can only view their own profile
    unless current_user.admin? || current_user == @user
      redirect_to root_path, alert: "You are not authorized to view this profile."
      return
    end
  end
  
  def reset_progress
    if current_user.reset_progress!
      redirect_to user_path(current_user), notice: "Your progress has been reset successfully!"
    else
      redirect_to user_path(current_user), alert: "There was an error resetting your progress."
    end
  end
  
  def social
    
  end
  
  private
  
  def require_admin
    unless current_user.admin?
      redirect_to authenticated_root_path, alert: "You are not authorized to access this page."
    end
  end
  
  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :role, :password, 
    :password_confirmation, :country, :quiz_attempts, :max_quiz_attempts, :nickname, :institution_id)
  end
end
