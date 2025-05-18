class AnswerOption < ApplicationRecord
  belongs_to :question
  
  validates :content, presence: true, if: -> { question&.multiple_choice? }
  validates :is_correct, inclusion: { in: [true, false] }
  
  private
  
  def at_least_one_correct_option
    # Count correct options
    correct_count = question&.answer_options&.reject(&:marked_for_destruction?)&.count(&:is_correct)
    
    if correct_count == 0
      errors.add(:base, "must have at least one correct answer")
    elsif correct_count > 1
      errors.add(:base, "can only have one correct answer")
    end
  end
end