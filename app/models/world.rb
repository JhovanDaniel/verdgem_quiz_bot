class World < ApplicationRecord
  belongs_to :subject
  
  has_one_attached :world_icon, dependent: :destroy
end
