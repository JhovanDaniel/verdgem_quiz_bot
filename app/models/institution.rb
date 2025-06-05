class Institution < ApplicationRecord
  has_many :users, dependent: :nullify
  
  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
end