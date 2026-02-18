class FaqTranslation < ApplicationRecord
  belongs_to :faq

  validates :locale, presence: true
  validates :domanda, presence: true
  validates :risposta, presence: true
  validates :locale, uniqueness: { scope: :faq_id, case_sensitive: false }
end

