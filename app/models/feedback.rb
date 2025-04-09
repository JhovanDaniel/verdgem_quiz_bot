class Feedback < ApplicationRecord
  belongs_to :quiz_session
  
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :quiz_session_id, uniqueness: { message: "has already been rated" }
  
  # Helper method to access user if needed
  def user
    quiz_session.user
  end
end

# app/models/quiz_session.rb
class QuizSession < ApplicationRecord
  has_one :feedback, dependent: :destroy
  # other associations...
end