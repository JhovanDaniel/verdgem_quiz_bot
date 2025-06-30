class SubjectTeacher < ApplicationRecord
  belongs_to :subject
  belongs_to :user
  
  validates :subject_id, presence: true
  validates :user_id, presence: true
  validates :user_id, uniqueness: { scope: :subject_id, message: "is already assigned to this subject" }
  
  # Ensure only teachers can be assigned
  validate :user_must_be_teacher
  
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :recent, -> { order(assigned_at: :desc) }
  
  private
  
  def user_must_be_teacher
    unless user&.teacher? || user&.admin?
      errors.add(:user, "must be a teacher or admin")
    end
  end
end