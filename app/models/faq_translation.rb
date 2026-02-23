class FaqTranslation < ApplicationRecord
  belongs_to :faq

  before_validation :normalize_locale

  validates :locale, presence: true
  validates :domanda, presence: true
  validates :risposta, presence: true
  validates :locale, uniqueness: { scope: :faq_id, case_sensitive: false }

  private

  def normalize_locale
    self.locale = locale.to_s.strip.tr("_", "-").downcase
  end
end
