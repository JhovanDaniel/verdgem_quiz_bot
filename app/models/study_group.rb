class StudyGroup < ApplicationRecord
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by_id'
  
  has_many :study_group_memberships, dependent: :destroy
  has_many :members, through: :study_group_memberships, source: :user
  has_many :active_memberships, -> { where(status: :active) }, class_name: 'StudyGroupMembership'
  has_many :active_members, through: :active_memberships, source: :user
  has_many :pending_memberships, -> { where(status: :pending) }, class_name: 'StudyGroupMembership'
  has_many :pending_members, through: :pending_memberships, source: :user
  
  has_many :admin_memberships, -> { where(role: [:admin, :leader]) }, class_name: 'StudyGroupMembership'
  has_many :admins, through: :admin_memberships, source: :user
  
  has_many :study_group_invitations, dependent: :destroy
  has_many :pending_invitations, -> { where(status: :pending) }, class_name: 'StudyGroupInvitation'
  
  validates :name, presence: true, length: { minimum: 3, maximum: 50 }, uniqueness: true
  validates :description, length: { maximum: 500 }
  validates :clan_motto, length: { maximum: 200 }
  validates :max_members, presence: true, numericality: { greater_than: 1, less_than_or_equal_to: 100 }
  validates :created_by_id, presence: true
  validates :clan_color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color" }
  
  scope :active, -> { where(is_active: true, archived_at: nil) }
  scope :top_by_points, -> { order(total_points: :desc) }
  scope :top_monthly, -> { order(monthly_points: :desc) }
  
  before_create :ensure_creator_membership
  
  has_one_attached :group_icon, dependent: :destroy
  
  def member_count
    active_members.count
  end
  
  def admin_count
    admins.count
  end
  
  def user_membership(user)
    study_group_memberships.find_by(user: user)
  end
  
  def user_role(user)
    membership = user_membership(user)
    membership&.role
  end
  
  def member?(user)
    study_group_memberships.active.exists?(user: user)
  end
  
  def admin?(user)
    study_group_memberships.active.where(user: user, role: [:admin, :leader]).exists?
  end
  
  def leader?(user)
    study_group_memberships.active.exists?(user: user, role: :leader)
  end
  
  def can_invite?(user)
    admin?(user)
  end
  
  def can_manage?(user)
    admin?(user)
  end
  
  def pending_invitation?(user)
    study_group_invitations.pending.exists?(invitee: user)
  end
  
  def invite_user(invitee, inviter, message: nil)
    return false if member?(invitee) || pending_invitation?(invitee)
    return false unless can_invite?(inviter)
    return false if full?
    
    study_group_invitations.create!(
      inviter: inviter,
      invitee: invitee,
      message: message,
      expires_at: 7.days.from_now
    )
  end
  
  def add_member(user, role: :member, invited_by: nil)
    return false if member?(user) || full?
    
    membership = study_group_memberships.create!(
      user: user,
      role: role,
      status: :active,
      joined_at: Time.current,
      invited_by: invited_by
    )
    
    # Cancel any pending invitations
    study_group_invitations.pending.where(invitee: user).update_all(
      status: :accepted,
      responded_at: Time.current
    )
    
    membership
  end
  
  def remove_member(user)
    membership = user_membership(user)
    return false unless membership
    return false if leader?(user) && admins.count == 1 # Can't remove last leader
    
    membership.destroy
  end
  
  def promote_to_admin(user, promoter)
    return false unless member?(user) && admin?(promoter)
    
    membership = user_membership(user)
    membership&.update(role: :admin)
  end
  
  def demote_from_admin(user, demoter)
    return false unless admin?(user) && (leader?(demoter) || user == demoter)
    return false if leader?(user) && admins.count == 1 # Can't demote last leader
    
    membership = user_membership(user)
    new_role = leader?(user) ? :admin : :member
    membership&.update(role: new_role)
  end
  
  def add_points(user, points, activity_type, description: nil, quiz_session: nil)
    return false unless member?(user)
    return false if points <= 0
    
    # Create point log
    #study_group_point_logs.create!(
      #user: user,
      #points_earned: points,
      #activity_type: activity_type,
      #description: description,
      #quiz_session: quiz_session,
      #earned_date: Date.current
    #)
    
    # Update group totals
    increment!(:total_points, points)
    increment!(:monthly_points, points)
    
    # Update member contribution
    membership = user_membership(user)
    if membership
      membership.increment!(:points_contributed, points)
      membership.increment!(:monthly_points_contributed, points)
      membership.increment!(:quizzes_completed_in_group) if activity_type == 'quiz_completion'
      membership.update!(last_active_at: Time.current)
    end
    
    true
  end
  
  def top_contributors(limit: 10, period: :all_time)
    case period
    when :weekly
      active_memberships.includes(:user).order(weekly_points_contributed: :desc).limit(limit)
    when :monthly
      active_memberships.includes(:user).order(monthly_points_contributed: :desc).limit(limit)
    else
      active_memberships.includes(:user).order(points_contributed: :desc).limit(limit)
    end
  end
  
  def reset_monthly_points!
    update!(monthly_points: 0, last_points_reset_at: Time.current)
    study_group_memberships.update_all(monthly_points_contributed: 0)
  end
  
  def average_points_per_member
    return 0 if member_count == 0
    total_points.to_f / member_count
  end
  
  def clan_rank
    StudyGroup.active.where('total_points > ?', total_points).count + 1
  end
  
  private
  
  def ensure_creator_membership
    self.study_group_memberships.build(
      user: creator,
      role: :leader,
      status: :active,
      joined_at: Time.current
    )
  end
  
end
