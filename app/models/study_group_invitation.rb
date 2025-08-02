class StudyGroupInvitation < ApplicationRecord
  belongs_to :study_group
  belongs_to :inviter, class_name: 'User'
  belongs_to :invitee, class_name: 'User'
  
  enum status: { pending: 0, accepted: 1, declined: 2, expired: 3 }
  
  scope :unexpired, -> { where('expires_at > ?', Time.current) }
  scope :recent, -> { order(created_at: :desc) }
  
  before_create :set_expiry_date
  
  def accept!
    return false if expired?
    
    transaction do
      study_group.add_member(invitee, invited_by: inviter)
      update!(status: :accepted, responded_at: Time.current)
    end
  end
  
  def decline!
    update!(status: :declined, responded_at: Time.current)
  end
  
  def expired?
    expires_at < Time.current
  end
  
  def set_expiry_date
    self.expires_at ||= 15.days.from_now
  end
  
end
