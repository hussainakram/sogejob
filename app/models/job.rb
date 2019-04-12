class Job < ApplicationRecord
  ################## Validations ##################
  validates :job_title, presence: true, length: { maximum: 255 }
  validates :company, presence: true, length: { maximum: 255 }
  validates :location, length: { maximum: 255 }
  validates :country, length: { maximum: 255 }
  validates :apply_link, length: { maximum: 255 }
  # validates_uniqueness_of :apply_link
end
