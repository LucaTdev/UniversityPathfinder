class Faq < ApplicationRecord
  BASE_LOCALE = :it

  belongs_to :faq_category, optional: true

  has_many :faq_votes, dependent: :destroy
  has_many :faq_translations, dependent: :destroy

  validates :domanda, presence: true
  validates :risposta, presence: true
  validates :categoria, presence: true

  def domanda_for(locale)
    translated_attr_for(locale, :domanda)
  end

  def risposta_for(locale)
    translated_attr_for(locale, :risposta)
  end

  def translation_for(locale)
    normalized = normalize_locale(locale)
    base = normalized.split("-").first
    return nil if normalized.blank? || base == BASE_LOCALE.to_s

    exact = faq_translations.find { |t| normalize_locale(t.locale) == normalized }
    return exact if exact

    return nil if base.blank?

    if normalized.include?("-")
      return faq_translations.find { |t| normalize_locale(t.locale) == base }
    end

    prefix = "#{normalized}-"
    faq_translations
      .select { |t| normalize_locale(t.locale).start_with?(prefix) }
      .min_by { |t| normalize_locale(t.locale) }
  end

  private

  def translated_attr_for(locale, attr)
    translation_for(locale)&.public_send(attr).presence || public_send(attr)
  end

  def normalize_locale(raw)
    raw.to_s.strip.tr("_", "-").downcase
  end
end
  
