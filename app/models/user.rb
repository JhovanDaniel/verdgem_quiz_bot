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
  validate :check_profanity_in_nickname, if: -> { nickname.present? }
  validate :check_profanity_in_first_name, if: -> { first_name.present? }
  validate :check_profanity_in_last_name, if: -> { last_name.present? }

  
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
  
  def completed_questions_from_finished_quizzes_count(start_date, end_date)
    question_attempts
      .joins(:quiz_session)
      .where(quiz_sessions: { completed_at: start_date..end_date })
      .where.not(score: nil)
      .count
  end
  
  # Total score from only completed quizzes
  def total_score_from_finished_quizzes(start_date, end_date)
    question_attempts
      .joins(:quiz_session)
      .where(quiz_sessions: { completed_at: start_date..end_date })
      .sum(:score) || 0
  end
  
  # Total max possible score from completed quizzes
  def max_possible_score_from_finished_quizzes(start_date, end_date)
    attempted_questions = question_attempts
      .joins(:quiz_session)
      .where(quiz_sessions: { completed_at: start_date..end_date })
      .includes(:question)
    
    attempted_questions.sum { |attempt| attempt.question.max_points }
  end
  
  # Percentage score from completed quizzes
  def score_percentage_from_finished_quizzes(start_date, end_date)
    max_score = max_possible_score_from_finished_quizzes(start_date, end_date)
    return 0 if max_score == 0
    
    (total_score_from_finished_quizzes(start_date, end_date).to_f / max_score) * 100
  end
  
  private
  
  def check_profanity_in_nickname
    check_profanity_in_attribute(:nickname)
  end
  
  # Method to check for profanity in first name
  def check_profanity_in_first_name
    check_profanity_in_attribute(:first_name)
  end
  
  # Method to check for profanity in last name
  def check_profanity_in_last_name
    check_profanity_in_attribute(:last_name)
  end
  
  # Generic method to check for profanity in any attribute
  def check_profanity_in_attribute(attribute)
    value = self.send(attribute)
    
    begin
      # Check using Obscenity gem
      if Obscenity.profane?(value)
        errors.add(attribute, "contains inappropriate language")
        return
      end
      
      # Load custom offensive words
      custom_words_path = Rails.root.join('config', 'offensive_words.txt')
      custom_words = File.exist?(custom_words_path) ? 
                    File.read(custom_words_path).split("\n").map(&:strip).reject(&:empty?) : 
                    []
      
      # Check custom words directly
      custom_words.each do |word|
        if value.downcase.include?(word.downcase)
          errors.add(attribute, "contains inappropriate language")
          return
        end
      end
      
      # Check leetspeak version
      leet_value = value.downcase
                        .gsub('0', 'o')
                        .gsub('1', 'i')
                        .gsub('3', 'e')
                        .gsub('4', 'a')
                        .gsub('5', 's')
                        .gsub('7', 't')
                        .gsub('@', 'a')
                        .gsub('$', 's')
      
      if leet_value != value.downcase
        # Check custom words against leetspeak version
        custom_words.each do |word|
          if leet_value.include?(word.downcase)
            errors.add(attribute, "contains inappropriate language")
            return
          end
        end
        
        # Check Obscenity against leetspeak version
        if Obscenity.profane?(leet_value)
          errors.add(attribute, "contains inappropriate language")
        end
      end
    rescue => e
      # Log error but don't block validation if checks fail
      Rails.logger.error "Error in profanity check for #{attribute}: #{e.message}"
    end
  end
  
end
