class Badge < ApplicationRecord
  has_many :user_badges, dependent: :destroy
  has_many :users, through: :user_badges
  
  has_one_attached :badge_image, dependent: :destroy
  validates :badge_image, content_type: { in: ['image/jpeg', 'image/png'], message: 'is not a JPG, or PNG file' }
  validates :badge_image, size: { less_than: 1.megabytes }
  
  validates :name, presence: true, uniqueness: true
  validates :conditions, presence: true
  validates :rarity, inclusion: { in: 1..5 }
  validates :category, presence: true
  
  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_rarity, ->(rarity) { where(rarity: rarity) }
  
  # Categories for organization
  CATEGORIES = %w[
    quiz_count
  ].freeze
  
  # Rarity levels
  RARITIES = {
    1 => 'Common',
    2 => 'Uncommon', 
    3 => 'Rare',
    4 => 'Epic',
  }.freeze
  
  def rarity_name
    RARITIES[rarity]
  end
  
  def rarity_color
    case rarity
    when 1 then '#F59E0B' # Gray
    when 2 then '#10B981' # Green  
    when 3 then '#3B82F6' # Blue
    when 4 then '#8B5CF6' # Purple
    end
  end
  
  def earned_count
    user_badges.count
  end
  
  def earned_percentage
    return 0 if User.count == 0
    (earned_count.to_f / User.count * 100).round(2)
  end
  
  # Check if badge is rare (less than 10% of users have it)
  def rare?
    earned_percentage < 10
  end
  
  def to_s
    name
  end
end