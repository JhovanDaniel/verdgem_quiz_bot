class SubTopic < ApplicationRecord
  belongs_to :topic
  has_many :questions
  has_many :quiz_sessions
  
  validates :name, presence: true
end