class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  attr_accessor :skip_password_validation
  
  def password_required?
    return false if skip_password_validation
    super
  end
         
  has_many :question_attempts, dependent: :destroy
  has_many :quiz_sessions, dependent: :destroy
  has_many :created_subjects, class_name: 'Subject', foreign_key: 'created_by_id'
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges
  has_many :user_level_progresses, dependent: :destroy
  
  has_many :subject_teachers, dependent: :destroy
  has_many :assigned_subjects, through: :subject_teachers, source: :subject
  has_many :active_subject_assignments, -> { where(subject_teachers: { active: true }) }, 
           through: :subject_teachers, source: :subject
           
  has_many :active_follows, class_name: 'UserFollow', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_follows, class_name: 'UserFollow', foreign_key: 'followee_id', dependent: :destroy
  
  has_many :following, through: :active_follows, source: :followee
  has_many :followers, through: :passive_follows, source: :follower
  
  has_many :study_group_memberships, dependent: :destroy
  has_many :study_groups, through: :study_group_memberships
  has_many :created_study_groups, class_name: 'StudyGroup', foreign_key: 'created_by_id', dependent: :destroy
  
  has_many :sent_study_group_invitations, class_name: 'StudyGroupInvitation', 
           foreign_key: 'inviter_id', dependent: :destroy
  has_many :received_study_group_invitations, class_name: 'StudyGroupInvitation', 
           foreign_key: 'invitee_id', dependent: :destroy
  has_many :pending_study_group_invitations, -> { where(status: :pending) }, 
           class_name: 'StudyGroupInvitation', foreign_key: 'invitee_id'
  
  belongs_to :institution, optional: true
         
  enum role: [:student, :teacher, :admin, :institution_admin]
         
  validates_presence_of :first_name, :last_name, :email, :role
  validates :email, presence: true, uniqueness: true
  validates :nickname, presence: true, uniqueness: true
  
  
  validate :check_profanity_in_nickname, if: -> { nickname.present? }
  validate :check_profanity_in_first_name, if: -> { first_name.present? }
  validate :check_profanity_in_last_name, if: -> { last_name.present? }
  
  # Level system constants
  BASE_XP = 25
  GROWTH_FACTOR = 1.5

  
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
    max_quiz_attempts - monthly_quiz_attempts
  end
  
  def monthly_quiz_attempts
    quiz_sessions
      .unscope(where: :archived)  # Remove the archived filter from default scope
      .where(started_at: Time.current.beginning_of_month..Time.current.end_of_month)
      .count
  end
  
  def can_attempt_quiz?
    monthly_quiz_attempts < max_quiz_attempts
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
  def completed_questions
    question_attempts
      .joins(:quiz_session)
  end
  
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
  
  def total_score_from_finished_quizzes(start_date = nil, end_date = nil)
    scope = question_attempts.joins(:quiz_session)
    
    if start_date && end_date
      scope = scope.where(quiz_sessions: { completed_at: start_date..end_date })
    else
      scope = scope.where.not(quiz_sessions: { completed_at: nil })
    end
    
    scope.sum(:score) || 0
  end
  
  def max_possible_score_from_finished_quizzes(start_date = nil, end_date = nil)
    scope = question_attempts.joins(:quiz_session).includes(:question)
    
    if start_date && end_date
      scope = scope.where(quiz_sessions: { completed_at: start_date..end_date })
    else
      scope = scope.where.not(quiz_sessions: { completed_at: nil })
    end
    
    scope.sum { |attempt| attempt.question.max_points }
  end
  
  # Percentage score from completed quizzes
  def score_percentage_from_finished_quizzes(start_date, end_date)
    max_score = max_possible_score_from_finished_quizzes(start_date, end_date)
    return 0 if max_score == 0
    
    (total_score_from_finished_quizzes(start_date, end_date).to_f / max_score) * 100
  end
  
  def reset_progress!
    # Set the reset timestamp to current time
    #update(reset_at: Time.current)
    
    # Reset quiz attempts count
    #update(quiz_attempts: 0)
    user_badges.destroy_all
    user_level_progresses.destroy_all
    quiz_sessions.update_all(archived: true)
    
    # You could also add more reset actions here if needed
    true
  end
  
  #Level system methods
  def total_xp
    total_score_from_finished_quizzes
  end
  
  # XP required to reach a specific level (e.g., level 3 requires 75 XP total)
  def xp_required_for_level(level_num)
    return 0 if level_num <= 1
    
    total_xp = 0
    1.upto(level_num - 1) do |lvl|
      total_xp += BASE_XP * lvl
    end
    
    total_xp
  end
  
  def level
    lvl = 1
    while xp_required_for_level(lvl + 1) <= total_xp
      lvl += 1
    end
    lvl
  end
  
  # XP threshold for the current level
  def xp_for_current_level
    xp_required_for_level(level)
  end
  
  # XP threshold for the next level
  def xp_for_next_level
    xp_required_for_level(level + 1)
  end
  
  # XP accumulated in the current level
  def xp_in_current_level
    total_xp - xp_for_current_level
  end
  
  # XP needed to reach the next level
  def xp_needed_for_next_level
    xp_for_next_level - total_xp
  end
  
  # Percentage progress to the next level (0-100)
  def xp_percentage
    puts "DEBUG: total_xp = #{total_xp}"
    puts "DEBUG: level = #{level}"
    puts "DEBUG: xp_for_current_level = #{xp_for_current_level}"
    puts "DEBUG: xp_for_next_level = #{xp_for_next_level}"
    puts "DEBUG: xp_in_current_level = #{xp_in_current_level}"
    
    return 0 if total_xp == 0
    
    current_level_range = xp_for_next_level - xp_for_current_level
    puts "DEBUG: current_level_range = #{current_level_range}"
    
    percentage = (xp_in_current_level.to_f / current_level_range * 100).round(1)
    puts "DEBUG: calculated percentage = #{percentage}"
    
    percentage
  end
  
  # Badge-related methods
  def has_badge?(badge)
    badges.include?(badge)
  end
  
  def featured_badges
    user_badges.featured.includes(:badge).limit(3)
  end
  
  def recent_badges(limit = 5)
    user_badges.recent.includes(:badge).limit(limit)
  end
  
  #----- Teacher methods -----#
  def assigned_subject_ids=(subject_ids)
    return unless teacher? || admin?
    
    # Remove blank values and ensure they're strings
    subject_ids = Array(subject_ids).reject(&:blank?).map(&:to_s)
    
    # Get current assignments
    current_subject_ids = subject_teachers.active.pluck(:subject_id).map(&:to_s)
    
    # Subjects to add
    subjects_to_add = subject_ids - current_subject_ids
    
    # Subjects to remove
    subjects_to_remove = current_subject_ids - subject_ids
    
    # Add new assignments
    subjects_to_add.each do |subject_id|
      if subject = Subject.find_by(id: subject_id)
        assign_to_subject!(subject)
      end
    end
    
    # Remove old assignments
    subjects_to_remove.each do |subject_id|
      if subject = Subject.find_by(id: subject_id)
        remove_from_subject!(subject)
      end
    end
  end
  
  def assigned_subject_ids
    assigned_subjects.pluck(:id)
  end

  def teaching_subjects
    return Subject.none unless teacher? || admin?
    assigned_subjects.where(subject_teachers: { active: true })
  end
  
  def can_teach?(subject)
    return false unless teacher? || admin?
    return true if admin? # Admins can teach any subject
    
    assigned_subjects.where(subject_teachers: { active: true }).include?(subject)
  end
  
  def assign_to_subject!(subject, notes: nil)
    return false unless teacher? || admin?
    
    assignment = subject_teachers.find_or_initialize_by(subject: subject)
    assignment.active = true
    assignment.assigned_at = Time.current
    assignment.notes = notes if notes.present?
    assignment.save!
  end
  
  def remove_from_subject!(subject)
    assignment = subject_teachers.find_by(subject: subject)
    assignment&.update!(active: false)
  end
  
  # Check if user has any teaching assignments
  def has_teaching_assignments?
    teacher? && subject_teachers.active.exists?
  end
  
  #-------------------- Follow Methods ----------------------------#
  
  def follow(user)
    return false if user == self
    return false if following?(user)
    
    active_follows.create(followee: user)
  end
  
  def unfollow(user)
    active_follows.find_by(followee: user)&.destroy
  end
  
  def following?(user)
    following.include?(user)
  end
  
  def followers_count
    followers.count
  end
  
  def following_count
    following.count
  end
  
  # Get users that both follow each other (mutual follows)
  def mutual_follows
    following.joins(:active_follows).where(user_follows: { followee_id: id })
  end
  
  # Get suggested users to follow (users with mutual connections)
  def suggested_follows(limit: 5)
    # Users followed by people you follow, but not by you
    User.joins(:passive_follows)
        .where(user_follows: { follower_id: following.pluck(:id) })
        .where.not(id: following.pluck(:id) + [id])
        .group(:id)
        .order('COUNT(user_follows.id) DESC')
        .limit(limit)
  end
  
  # Get activity feed from followed users (recent quiz sessions)
  def following_activity(limit: 10)
    QuizSession.joins(:user)
               .where(user_id: following.pluck(:id))
               .where.not(completed_at: nil)
               .includes(:user, :subject, :topic)
               .order(completed_at: :desc)
               .limit(limit)
  end
  
  #-------------------- Study Group Methods ----------------------------#
  
  def is_study_group_member?
    study_group_memberships.active.exists?
  end

  def study_group_member?(group)
    study_group_memberships.active.exists?(study_group: group)
  end
  
  def study_group_admin?(group)
    membership = study_group_memberships.active.find_by(study_group: group)
    membership&.admin? || membership&.leader?
  end

  def study_group_leader?(group)
    study_group_memberships.active.exists?(study_group: group, role: :leader)
  end
  
  def study_group_leader?(group)
    study_group_memberships.active.exists?(study_group: group, role: :leader)
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
