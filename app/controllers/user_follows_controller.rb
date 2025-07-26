class UserFollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user, only: [:create, :destroy]
  
  def create
    @follow = current_user.active_follows.build(followee: @user)
    
    if @follow.save
      redirect_to authenticated_root_path, notice: "You are now following #{@user.nickname}"
    else
      respond_to do |format|
        format.html { redirect_back(fallback_location: user_path(@user), alert: @follow.errors.full_messages.join(', ')) }
        format.json { render json: { status: 'error', errors: @follow.errors.full_messages } }
      end
    end
  end
  
  def destroy
    @follow = current_user.active_follows.find_by(followee: @user)
    
    if @follow&.destroy
      redirect_to authenticated_root_path, notice: "You have unfollowed #{@user.nickname}"
    else
      respond_to do |format|
        format.html { redirect_back(fallback_location: user_path(@user), alert: "Unable to unfollow user") }
        format.json { render json: { status: 'error', message: 'Unable to unfollow user' } }
      end
    end
  end
  
  # Show users that the current user is following
  def following
    @user = User.find(params[:user_id])
    @following = @user.following.includes(:institution)
    
    # Security check
    unless current_user.admin? || current_user == @user
      redirect_to root_path, alert: "You are not authorized to view this information."
      return
    end
  end
  
  # Show users that are following the current user
  def followers
    @user = User.find(params[:user_id])
    @followers = @user.followers.includes(:institution)
    
    # Security check
    unless current_user.admin? || current_user == @user
      redirect_to root_path, alert: "You are not authorized to view this information."
      return
    end
  end
  
  # Show mutual follows
  def mutual
    @user = User.find(params[:user_id])
    @mutual_follows = @user.mutual_follows.includes(:institution).page(params[:page]).per(20)
    
    # Security check
    unless current_user.admin? || current_user == @user
      redirect_to root_path, alert: "You are not authorized to view this information."
      return
    end
  end
  
  # Activity feed from followed users
  def feed
    @activities = current_user.following_activity(limit: 20)
    @suggested_follows = current_user.suggested_follows
  end
  
  private
  
  def find_user
    @user = User.find(params[:user_id] || params[:id])
  end
end
