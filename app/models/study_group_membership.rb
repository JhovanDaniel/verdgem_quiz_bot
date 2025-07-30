class StudyGroupMembership < ApplicationRecord
  belongs_to :study_group
  belongs_to :user
  belongs_to :invited_by, class_name: 'User', optional: true
  
  enum role: { member: 0, admin: 1, leader: 2 }
  enum status: { pending: 0, active: 1, inactive: 2, banned: 3 }
  
  # Validate that user can only have one active membership
  validates :user_id, uniqueness: { 
    scope: :status, 
    conditions: -> { where(status: :active) },
    message: "can only belong to one active study group at a time"
  }
  
  
  scope :recent, -> { order(joined_at: :desc) }
  scope :by_contribution, -> { order(points_contributed: :desc) }
  
  def contribution_percentage
    return 0 if study_group.total_points == 0
    (points_contributed.to_f / study_group.total_points * 100).round(1)
  end
  
end
