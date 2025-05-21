class Topic < ApplicationRecord
  belongs_to :subject
  has_many :quiz_sessions
  has_many :questions, dependent: :destroy
  has_many :sub_topics, dependent: :destroy
  
  validates :name, presence: true
  
  def all_questions
    Question.where(topic_id: id).or(Question.where(sub_topic_id: sub_topics.select(:id)))
  end
end