class Institution < ApplicationRecord
  has_many :users, dependent: :nullify
  
  has_one_attached :institution_logo, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :contact_email, presence: true
  validates :phone, presence: true
  validates :address, presence: true

  scope :active, -> { where(active: true) }
  
  def status
    if active == true
      institution_status = "<span class='badge badge-primary rounded-lg mx-2'>●</span><span class=''>Active</span>"
      institution_status.html_safe
    else
      institution_status = "<span class='badge badge-danger rounded-lg mx-2'>●</span><span class=''>Inactive</span>"
      institution_status.html_safe
    end
  end
  
  def total_students
    users.where(role: :student).count
  end
  
  def quiz_completion_rate
    total_started = QuizSession.joins(:user)
                              .where(users: { institution_id: id, role: User.roles[:student] })
                              .count

    total_completed = QuizSession.joins(:user)
                                .where(users: { institution_id: id, role: User.roles[:student] })
                                .where.not(completed_at: nil)
                                .count

    return 0 if total_started == 0
    ((total_completed.to_f / total_started) * 100).round(1)
  end
  
  def total_quizzes_completed
    QuizSession.joins(:user)
               .where(users: { institution_id: self.id, role: User.roles[:student] })
               .where.not(completed_at: nil)
               .count
  end
  
  def average_quiz_score
    QuizSession.joins(:user)
               .where(users: { institution_id: self.id, role: User.roles[:student] })
               .where.not(completed_at: nil, total_score: nil, max_score: nil)
               .where('max_score > 0')
               .average('(total_score::float / max_score::float) * 100')
               &.round(1) || 0
  end
  
  #Points statistics------------------------------
  
  def total_student_points
    # Get total points from all students' finished quizzes
    QuizSession.joins(:user)
               .where(users: { institution_id: id, role: User.roles[:student] })
               .joins(:question_attempts)
               .where.not(quiz_sessions: { completed_at: nil })
               .sum('question_attempts.score') || 0
  end
  
  def average_student_points
    student_count = students.count
    return 0 if student_count == 0
    (total_student_points.to_f / student_count).round(1)
  end
  
   # Get ranking among all institutions
  def points_ranking
    institutions_with_points = Institution.joins(:users)
     .where(users: { role: User.roles[:student] })
     .group('institutions.id')
     .select(
       'institutions.id',
       'institutions.name',
       'COALESCE(SUM(CASE 
         WHEN quiz_sessions.completed_at IS NOT NULL 
         THEN question_attempts.score 
         ELSE 0 
       END), 0) as total_points'
     )
     .joins('LEFT JOIN quiz_sessions ON quiz_sessions.user_id = users.id')
     .joins('LEFT JOIN question_attempts ON question_attempts.quiz_session_id = quiz_sessions.id')
     .order('total_points DESC')
    
    institutions_with_points.find_index { |inst| inst.id == self.id } + 1
  end
  
  #Get all institutions ranked by points
  def self.ranked_by_points(limit = nil)
    query = joins(:users)
            .where(users: { role: User.roles[:student] })
            .joins('LEFT JOIN quiz_sessions ON quiz_sessions.user_id = users.id AND quiz_sessions.completed_at IS NOT NULL')
            .joins('LEFT JOIN question_attempts ON question_attempts.quiz_session_id = quiz_sessions.id')
            .group('institutions.id')
            .select(
              'institutions.*',
              'COALESCE(SUM(question_attempts.score), 0) as total_points',
              'COUNT(DISTINCT users.id) as student_count',
              'CASE 
                WHEN COUNT(DISTINCT users.id) > 0 
                THEN COALESCE(SUM(question_attempts.score), 0)::float / COUNT(DISTINCT users.id) 
                ELSE 0 
              END as average_points_per_student'
            )
            .order('total_points DESC')
    
    query = query.limit(limit) if limit
    query
  end
  
  
end