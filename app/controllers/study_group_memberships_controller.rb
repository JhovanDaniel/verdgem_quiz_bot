class StudyGroupMembershipsController < ApplicationController
  
  before_action :authenticate_user!
  before_action :set_study_group
  before_action :set_membership, only: [:promote, :demote, :destroy]
  before_action :require_admin
  
  def promote
    current_membership = @study_group.user_membership(current_user)
    
    case @membership.role
    when 'member'
      # Member -> Admin (simple promotion)
      @membership.update!(role: :admin)
      redirect_back(fallback_location: @study_group, 
        notice: "#{@membership.user.name} has been promoted to admin.")
        
    when 'admin' 
      # Admin -> Leader (only current leader can do this, and they become admin)
      unless current_membership.leader?
        redirect_back(fallback_location: @study_group, 
          alert: "Only the current leader can promote someone to leader.")
        return
      end
      
      StudyGroupMembership.transaction do
        # Demote current leader to admin
        current_membership.update!(role: :admin)
        
        # Promote admin to leader
        @membership.update!(role: :leader)
      end
      
      redirect_back(fallback_location: @study_group, 
        notice: "#{@membership.user.name} is now the leader! You have been demoted to admin.")
        
    when 'leader'
      redirect_back(fallback_location: @study_group, 
        alert: "#{@membership.user.name} is already the leader.")
    end
  end
  
  def demote
    # Only leaders can demote admins, and can't demote themselves if they're the only leader
    unless current_user_can_demote?
      redirect_back(fallback_location: @study_group, 
        alert: "You don't have permission to demote this user.")
      return
    end
    
    new_role = @membership.leader? ? :admin : :member
    @membership.update!(role: new_role)
    
    redirect_back(fallback_location: @study_group, 
      notice: "#{@membership.user.name} has been demoted to #{new_role}.")
  end
  
  def destroy
    member_name = @membership.user.name
    
    # Prevent removing the only leader
    if @membership.leader? && @study_group.admins.count == 1
      redirect_back(fallback_location: @study_group, 
        alert: "Cannot remove the only leader. Promote another member to admin first.")
      return
    end
    
    # Prevent non-leaders from removing leaders or other admins (except themselves)
    current_membership = @study_group.user_membership(current_user)
    unless can_remove_member?(current_membership)
      redirect_back(fallback_location: @study_group, 
        alert: "You don't have permission to remove this member.")
      return
    end
    
    @membership.destroy
    redirect_back(fallback_location: @study_group, 
      notice: "#{member_name} has been removed from #{@study_group.name}.")
  end
  
  private
  
  def set_study_group
    @study_group = StudyGroup.find(params[:study_group_id])
  end
  
  def set_membership
    @membership = @study_group.study_group_memberships.find(params[:id])
  end
  
  def require_admin
    unless @study_group.admin?(current_user)
      redirect_back(fallback_location: @study_group, 
        alert: "You need admin privileges to manage members.")
    end
  end
  
  def current_user_can_demote?
    current_membership = @study_group.user_membership(current_user)
    
    # Leaders can demote anyone except themselves if they're the only leader
    if current_membership.leader?
      return false if @membership.leader? && @study_group.admins.count == 1
      return true
    end
    
    # Admins can only demote themselves
    current_membership.admin? && @membership == current_membership
  end
  
  def can_remove_member?(current_membership)
    # Leaders can remove anyone except themselves if they're the only leader
    if current_membership.leader?
      return false if @membership.leader? && @study_group.admins.count == 1
      return true
    end
    
    # Admins can only remove regular members and themselves
    if current_membership.admin?
      return true if @membership.member? || @membership == current_membership
      return false
    end
    
    false
  end

end
