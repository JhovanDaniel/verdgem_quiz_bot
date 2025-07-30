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
  end
  
  def edit
  end
  
  def update
  end
  
  def show
  end
  
  def join
  end
  
  def leave
  end
  
  def invite_user
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
    params.require(:study_group).permit(:name, :description, :clan_motto, :is_private, :max_members, 
                                        :subject_focus, :group_rules, :clan_banner_color, :clan_icon)
  end
end
