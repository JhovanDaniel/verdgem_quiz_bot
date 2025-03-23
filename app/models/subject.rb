class Subject < ApplicationRecord
  has_many :topics, dependent: :destroy
  has_many :questions, through: :topics
  belongs_to :created_by, class_name: 'User', optional: true
  
  validates :name, presence: true, uniqueness: true
end