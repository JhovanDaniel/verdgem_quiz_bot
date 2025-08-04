module UsersHelper
  def can_remove_member?(current_user_membership, target_membership)
    return false unless current_user_membership
    
    # Leaders can remove admins and members (but not other leaders or themselves)
    if current_user_membership.leader?
      return false if target_membership.leader? # Can't remove other leaders
      return true if target_membership.admin? || target_membership.member?
    end
    
    # Admins can only remove regular members (not other admins or leaders)
    if current_user_membership.admin?
      return true if target_membership.member?
      return false # Can't remove admins or leaders
    end
    
    false # Members can't remove anyone
  end
end
