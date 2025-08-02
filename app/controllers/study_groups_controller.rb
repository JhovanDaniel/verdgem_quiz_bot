class StudyGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_group, only: [:show, :edit, :update, :join, :leave, :invite_user, :remove_member, :promote_member, :demote_member]
  before_action :require_membership, only: [:show]
  before_action :require_admin, only: [:edit, :update, :invite_user, :remove_member, :promote_member, :demote_member]
  before_action :require_leader, only: []
  
  def new
    @study_group = StudyGroup.new
  end
  
  def create
    @study_group = StudyGroup.new(study_group_params)
    @study_group.created_by_id = current_user.id

    if @study_group.save
      redirect_to study_group_path(@study_group), notice: "Study group was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @study_group.update(study_group_params)
      redirect_to study_group_path(@study_group), notice: 'Study group was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def show
    @membership = @study_group.user_membership(current_user)
    @members = @study_group.members
    #@top_contributors = @study_group.top_contributors(10)
  end
  
  def join
    if current_user.study_group_member?
      redirect_back(fallback_location: @study_group, 
        alert: "You must leave your current study group (#{current_user.current_study_group.name}) before joining another.")
    elsif @study_group.add_member(current_user)
      redirect_to @study_group, notice: "Welcome to #{@study_group.name}! You've joined the clan."
    else
      redirect_back(fallback_location: @study_group, alert: 'Unable to join this study group.')
    end
  end
  
  def leave
    if current_user.leave_current_study_group
      redirect_to social_path, notice: 'You have left your study group.'
    else
      redirect_back(fallback_location: @study_group, 
        alert: 'Cannot leave - you are the only leader. Promote another member first.')
    end
  end
  
  def invite_user
    puts "Params: #{params.inspect}"
    puts "Invitee param: #{params[:invitee]}"
    invitee = User.find(params[:invitee])
    
    if @study_group.invite_user(invitee, current_user)
      redirect_back(fallback_location: @study_group, 
        notice: "Invitation sent to #{invitee.name}!")
    else
      redirect_back(fallback_location: @study_group, 
        alert: "Unable to invite #{invitee.name}. They may already be a member or have a pending invitation.")
    end
  end
  
  def remove_member
  end
  
  def promote_member
  end
  
  def demote_member
  end
    
  def index
    @study_groups = StudyGroup.active.includes(:active_members, :creator)
    
    # Apply filters
    @study_groups = @study_groups.public_groups unless params[:show_private] && current_user.admin?
    @study_groups = @study_groups.by_subject(params[:subject]) if params[:subject].present?
    
    # Apply search
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @study_groups = @study_groups.where("LOWER(name) LIKE ? OR LOWER(description) LIKE ?", search_term, search_term)
    end
    
    # Apply sorting
    case params[:sort]
    when 'popular'
      @study_groups = @study_groups.popular
    when 'points'
      @study_groups = @study_groups.top_by_points
    when 'recent'
      @study_groups = @study_groups.recent
    else
      @study_groups = @study_groups.top_by_points
    end
    
    @study_groups = @study_groups.page(params[:page]).per(12) if defined?(Kaminari)
  end
  
  private
  
  def set_study_group
    @study_group = StudyGroup.find(params[:id])
  end
  
  def require_membership
    unless @study_group.member?(current_user) || current_user.admin?
      redirect_to study_groups_path, alert: 'You must be a member to access this study group.'
    end
  end
  
  def require_admin
    unless @study_group.can_manage?(current_user)
      redirect_to @study_group, alert: 'You need admin privileges to perform this action.'
    end
  end
  
  def require_leader
    unless @study_group.leader?(current_user) || current_user.admin?
      redirect_to @study_group, alert: 'Only the group leader can perform this action.'
    end
  end
  
  def study_group_params
    params.require(:study_group).permit(:name, :description, :clan_motto, :clan_color, :group_icon,
                                        :created_by_id)
  end
end
