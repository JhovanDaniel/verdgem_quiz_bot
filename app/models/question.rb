class Question < ApplicationRecord
  
  belongs_to :topic
  has_many :question_attempts, dependent: :destroy
  has_many :answer_options, dependent: :destroy
  
  enum difficulty_level: [:easy, :medium, :hard]
  enum question_type: [:multiple_choice, :long_answer], _default: :multiple_choice
  
  validates :content, presence: true
  validates :model_answer, presence: true, if: :long_answer?
  validates :marking_criteria, presence: true, if: :long_answer?
  validates :max_points, numericality: { greater_than: 0 }
  
  validate :mc_correct_answer, if: :multiple_choice?
  
  accepts_nested_attributes_for :answer_options, allow_destroy: true, reject_if: :all_blank
  
  # Default values for new questions
  after_initialize :set_defaults, if: :new_record?
  
  def long_answer?
    question_type == 'long_answer'
  end
  
  private
  
  def mc_correct_answer
    return if answer_options.empty?
    
    correct_count = answer_options.count { |option| option.is_correct? }
    
    if correct_count == 0
      errors.add(:base, 'Question must have at least one correct answer')
    end
    
    if correct_count > 1
      errors.add(:base, 'Question can only have one correct answer')
    end
  end
  
  def set_defaults
    self.max_points ||= 5
    self.difficulty_level ||= 'medium'
  end
end