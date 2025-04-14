class QuestionAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :question
  belongs_to :quiz_session, optional: true
  
  validates :student_answer, presence: true
  
  # Optional: Add a method to check if this attempt was correct
  def correct?
    score.to_f / max_score.to_f >= 0.7 # Consider 70%+ as correct
  end
  
  def max_score
    question.max_points
  end
  
  def self.question_character_image
    character_images = {
      "character_expressions/jade-happy.png" => "Jade Happy",
      "character_expressions/jade-excited.png" => "Jade Excited",
      "character_expressions/jade-party.png" => "Jade Party",
      "character_expressions/jade-shocked.png" => "Jade Shocked",
      "character_expressions/emeri-happy.png" => "Emeri Happy",
      "character_expressions/emeri-excited.png" => "Emeri Excited",
      "character_expressions/emeri-party.png" => "Emeri Party",
      "character_expressions/emeri-shocked.png" => "Emeri Shocked",
      "character_expressions/peri-happy.png" => "Peri Happy",
      "character_expressions/peri-excited.png" => "Peri Excited",
      "character_expressions/peri-party.png" => "Peri Party",
      "character_expressions/peri-shocked.png" => "Peri Shocked",
      "character_expressions/jasper-happy.png" => "Jasper Happy",
      "character_expressions/jasper-excited.png" => "Jasper Excited",
      "character_expressions/jasper-party.png" => "Jasper Party",
      "character_expressions/jasper-shocked.png" => "Jasper Shocked",
    }
    
    character_images.to_a.sample
  end
    
end