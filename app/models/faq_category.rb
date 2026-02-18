class FaqCategory < ApplicationRecord
  has_many :faqs, dependent: :nullify
  has_many :faq_suggestions, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
