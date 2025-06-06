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
end