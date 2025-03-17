class Subject < ApplicationRecord
  has_many :topics, dependent: :destroy
  has_many :questions, through: :topics
  
  validates :name, presence: true, uniqueness: true
end