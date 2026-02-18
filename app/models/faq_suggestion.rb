class FaqSuggestion < ApplicationRecord
  belongs_to :user
  belongs_to :faq_category, optional: true
  belongs_to :faq, optional: true

  enum :status, { attesa: 0, accettata: 1, rifiutata: 2 }, default: :attesa

  validates :domanda, presence: true
  validates :categoria, presence: true
end
