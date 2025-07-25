class UserFollow < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followee, class_name: 'User'
  
  validates :follower_id, presence: true
  validates :followee_id, presence: true
  validates :follower_id, uniqueness: { scope: :followee_id, message: "You are already following this user" }
  
  # Prevent users from following themselves
  validate :cannot_follow_self
  
  scope :recent, -> { order(created_at: :desc) }
  
  private
  
  def cannot_follow_self
    if follower_id == followee_id
      errors.add(:followee, "You cannot follow yourself")
    end
  end
end