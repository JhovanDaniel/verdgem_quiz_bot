class UserBadge < ApplicationRecord
  belongs_to :user
  belongs_to :badge
  belongs_to :quiz_session, optional: true
  
  validates :user_id, uniqueness: { scope: :badge_id }
  validates :earned_at, presence: true
  
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(earned_at: :desc) }
  scope :by_category, ->(category) { joins(:badge).where(badges: { category: category }) }
  scope :by_rarity, ->(rarity) { joins(:badge).where(badges: { rarity: rarity }) }
  
  def days_since_earned
    (Time.current - earned_at) / 1.day
  end
  
  def recently_earned?
    days_since_earned <= 7
  end
  
  private
  
end