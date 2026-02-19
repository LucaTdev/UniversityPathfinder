class Route < ApplicationRecord
  belongs_to :user
  
  validates :destination, presence: true
  validates :destination_name, presence: true
  
  scope :recent, -> { order(searched_at: :desc) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
end