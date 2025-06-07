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
end