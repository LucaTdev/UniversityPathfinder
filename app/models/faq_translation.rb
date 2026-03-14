class FaqTranslation < ApplicationRecord
  belongs_to :faq

  before_validation :normalize_locale
  after_create_commit :publish_translation_news_item

  validates :locale, presence: true
  validates :domanda, presence: true
  validates :risposta, presence: true
  validates :locale, uniqueness: { scope: :faq_id, case_sensitive: false }

  private

  def publish_translation_news_item
    News.create!(
      title: "Nuova traduzione FAQ",
      content: translation_news_content,
      category: "FAQ",
      icon_class: "fas fa-language",
      published_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error("[FAQ] Impossibile creare news traduzione per FAQ ##{faq_id}: #{e.class} #{e.message}")
  end

  def translation_news_content
    base = faq&.domanda.to_s
    code = locale.to_s.strip
    return base if code.blank?

    "#{base} (#{code.upcase})"
  end

  def normalize_locale
    self.locale = locale.to_s.strip.tr("_", "-").downcase
  end
end
