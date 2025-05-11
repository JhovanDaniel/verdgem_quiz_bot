class AnswerOption < ApplicationRecord
  belongs_to :question
  
  validates :content, presence: true
  validates :is_correct, inclusion: { in: [true, false] }
  
  # Make sure at least one answer option is correct for multiple choice questions
  validate :at_least_one_correct_option, if: -> { question&.multiple_choice? }
  
  private
  
  def at_least_one_correct_option
    # This validation should ideally be at the Question level, but this is a simplified version
    if question&.answer_options&.select(&:is_correct).blank?
      errors.add(:is_correct, "At least one option must be correct")
    end
  end
end