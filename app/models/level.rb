class Level < ApplicationRecord
  belongs_to :world
  belongs_to :sub_topic
  has_many :user_level_progresses, dependent: :destroy
  belongs_to :prerequisite_level, class_name: 'Level', optional: true
  
  has_one :dependent_levels, class_name: 'Level', foreign_key: 'prerequisite_level_id'

  has_one_attached :level_icon, dependent: :destroy
  
  validates :name, presence: true
  validates :difficulty, presence: true, inclusion: { in: %w[easy medium hard] }
  validates :position, presence: true, uniqueness: { scope: :world_id }
  validates :question_count, presence: true, numericality: { greater_than: 0 }
  validates :passing_score_percentage, presence: true, numericality: { in: 70..100 }
  
  enum question_type: { mixed: 0, multiple_choice: 1, long_answer: 2 } 
  enum difficulty: [:easy, :medium, :hard]
  
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position) }
  scope :by_difficulty, ->(diff) { where(difficulty: diff) }
  
  def unlocked_for?(user)
    return true if prerequisite_level.nil?
    
    UserLevelProgress.exists?(
      user: user, 
      level: prerequisite_level, 
      completed: true
    )
  end
  
  def completed_by?(user)
    UserLevelProgress.exists?(
      user: user,
      level: self,
      completed: true
    )
  end
  
  def status_for(user)
    return :locked unless unlocked_for?(user)
    return :completed if completed_by?(user)
    
    progress = user_world_progresses.find_by(user: user)
    return :available unless progress
    return :in_progress if progress.attempts > 0
    :available
  end
  
  def progress_for(user)
    user_level_progresses.find_by(user: user)
  end
  
  def attempts_by(user)
    progress_for(user)&.attempts || 0
  end
  
  def best_score_by(user)
    progress_for(user)&.best_score || 0
  end
  
  def start_quiz_for(user)
    # Use existing question selection logic but with level parameters
    questions_scope = Question.joins(:topic)
    
    # Filter by world's subject
    questions_scope = questions_scope.where(topics: { subject_id: world.subject_id })
    
    # Filter by level's topic/sub_topic if specified
    questions_scope = questions_scope.where(topic_id: topic.id) if topic.present?
    questions_scope = questions_scope.where(sub_topic_id: sub_topic.id) if sub_topic.present?
    
    # Filter by difficulty
    questions_scope = questions_scope.where(difficulty_level: difficulty)
    
    # Filter by question type unless mixed
    unless question_type == "mixed"
      questions_scope = questions_scope.where(question_type: question_type)
    end
    
    # Select random questions up to the requested count
    questions_scope.order("RANDOM()").limit(question_count)
  end
end
