class Faq < ApplicationRecord
  belongs_to :faq_category, optional: true

  has_many :faq_votes, dependent: :destroy
  has_many :faq_translations, dependent: :destroy

  validates :domanda, presence: true
  validates :risposta, presence: true
  validates :categoria, presence: true
end
  
