class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :question_attempts, dependent: :destroy
  has_many :quiz_sessions, dependent: :destroy
  has_many :created_subjects, class_name: 'Subject', foreign_key: 'created_by_id'
         
  enum role: [:student, :teacher, :admin]
         
  validates_presence_of :first_name, :last_name, :email, :role
  validate :nickname_not_offensive, if: -> { nickname.present? }

  
  def name
    "#{first_name} #{last_name}"
  end
  
  def initials
    "#{first_name.first}#{last_name.first}".upcase 
  end
  
  def increment_quiz_attempts!
    update(quiz_attempts: quiz_attempts + 1)
  end
  
  def attempts_remaining
    max_quiz_attempts - quiz_attempts
  end
  
  def can_attempt_quiz?
    quiz_attempts < max_quiz_attempts
  end
  
  def quiz_limit_reached?
    !can_attempt_quiz?
  end
  
  def update_with_password(params)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    
    update(params)
  end
  
  #Leaderboard methods
  def total_score(start_date = nil, end_date = nil)
    scope = question_attempts
    scope = scope.where(created_at: start_date..end_date) if start_date && end_date
    scope.sum(:score)
  end
  
  def total_possible_score(start_date = nil, end_date = nil)
    scope = question_attempts.joins(:question)
    scope = scope.where(question_attempts: { created_at: start_date..end_date }) if start_date && end_date
    scope.sum('questions.max_points')
  end
  
  def score_percentage(start_date = nil, end_date = nil)
    possible = total_possible_score(start_date, end_date)
    return 0 if possible == 0
    (total_score(start_date, end_date).to_f / possible * 100).round(1)
  end
  
  def completed_questions_count(start_date = nil, end_date = nil)
    scope = question_attempts.where.not(score: nil)
    scope = scope.where(created_at: start_date..end_date) if start_date && end_date
    scope.count
  end
  
  private
  
  def nickname_not_offensive
    # Check original nickname
    if Obscenity.profane?(nickname)
      errors.add(:nickname, "contains inappropriate language")
      return
    end
    
    # Check leetspeak version
    leet_nickname = nickname.downcase
                           .gsub('0', 'o')
                           .gsub('1', 'i')
                           .gsub('3', 'e')
                           .gsub('4', 'a')
                           .gsub('5', 's')
                           .gsub('7', 't')
                           .gsub('@', 'a')
                           .gsub('$', 's')
    
    if leet_nickname != nickname.downcase && Obscenity.profane?(leet_nickname)
      errors.add(:nickname, "contains inappropriate language")
    end
  end
  
end
