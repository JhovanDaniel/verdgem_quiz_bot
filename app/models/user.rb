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
end
