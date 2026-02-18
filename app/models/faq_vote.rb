class FaqVote < ApplicationRecord
  belongs_to :faq
  belongs_to :user

  validates :value, inclusion: { in: [1, -1] }
  validates :user_id, uniqueness: { scope: :faq_id }
end

