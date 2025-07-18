class Subject < ApplicationRecord
  has_many :topics, dependent: :destroy
  has_many :questions, through: :topics
  belongs_to :created_by, class_name: 'User', optional: true
  has_one :world
  
  has_many :subject_teachers, dependent: :destroy
  has_many :teachers, through: :subject_teachers, source: :user
  has_many :active_teachers, -> { where(subject_teachers: { active: true }) }, 
           through: :subject_teachers, source: :user
  
  validates :name, presence: true, uniqueness: true
  
  #----- Teacher methods -----#
  
  def assign_teacher!(user, notes: nil)
    return false unless user.teacher? || user.admin?
    
    assignment = subject_teachers.find_or_initialize_by(user: user)
    assignment.active = true
    assignment.assigned_at = Time.current
    assignment.notes = notes if notes.present?
    assignment.save!
  end
  
  def remove_teacher!(user)
    assignment = subject_teachers.find_by(user: user)
    assignment&.update!(active: false)
  end
  
  def has_active_teachers?
    subject_teachers.active.exists?
  end
  
  def teacher_count
    subject_teachers.active.count
  end
  
end