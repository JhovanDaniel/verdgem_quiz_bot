class Question < ApplicationRecord
  belongs_to :topic
  has_many :question_attempts, dependent: :destroy
  
  validates :content, presence: true
  validates :model_answer, presence: true
  validates :max_points, numericality: { greater_than: 0 }
  
  # Default values for new questions
  after_initialize :set_defaults, if: :new_record?
  
  private
  
  def set_defaults
    self.max_points ||= 5
    self.difficulty_level ||= 'medium'
  end
end