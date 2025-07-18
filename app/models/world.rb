class World < ApplicationRecord
  belongs_to :subject
  has_many :levels, -> { where(active: true).order(:position) }, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(is_active: true) }
  scope :with_levels, -> { includes(:levels) }
  
  has_one_attached :world_icon, dependent: :destroy
  
  def completion_percentage_for(user)
    total_levels = levels.count
    return 0 if total_levels == 0
    
    completed_levels = UserLevelProgress.joins(:level)
                                       .where(levels: { world_id: id })
                                       .where(user: user, completed: true)
                                       .count
    
    (completed_levels.to_f / total_levels * 100).round(2)
  end
  
  def completed_levels_for(user)
    UserLevelProgress.joins(:level)
                     .where(levels: { world_id: id })
                     .where(user: user, completed: true)
                     .count
  end
  
  def total_levels
    levels.count
  end
  
  def completed_levels_for(user)
    UserLevelProgress.joins(:level)
                     .where(levels: { world_id: id })
                     .where(user: user, completed: true)
                     .count
  end
  
  def status_for(user)
    completion = completion_percentage_for(user)
    
    case completion
    when 0
      :not_started
    when 100
      :completed
    else
      :in_progress
    end
  end
end
