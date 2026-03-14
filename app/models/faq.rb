class Faq < ApplicationRecord
  BASE_LOCALE = :it

  belongs_to :faq_category, optional: true

  has_many :faq_votes, dependent: :destroy
  has_many :faq_translations, dependent: :destroy

  before_validation :sync_category_fields
  after_create_commit :publish_news_item
  after_update_commit :publish_update_news_item, if: :publish_update_news_item?

  validates :domanda, presence: true
  validates :risposta, presence: true
  validates :categoria, presence: true
  validates :faq_category, presence: true

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

  def sync_category_fields
    if faq_category_id.present? && faq_category.nil?
      self.faq_category = FaqCategory.find_by(id: faq_category_id)
    end

    if faq_category.present?
      self.categoria = faq_category.name
    else
      raw = categoria.to_s.strip.squish
      if raw.present?
        found = FaqCategory.where("lower(name) = ?", raw.downcase).first
        if found
          self.faq_category = found
          self.categoria = found.name
        end
      end
    end

    if faq_category.blank?
      general = FaqCategory.general!
      self.faq_category = general
      self.categoria = general.name
    end

    self.categoria = categoria.to_s.strip.squish
  end

  def publish_news_item
    News.create!(
      title: "Pubblicazione nuova FAQ",
      content: domanda.to_s,
      category: "FAQ",
      icon_class: "fas fa-question-circle",
      published_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error("[FAQ] Impossibile creare news per FAQ ##{id}: #{e.class} #{e.message}")
  end

  def publish_update_news_item?
    saved_change_to_domanda? || saved_change_to_risposta?
  end

  def publish_update_news_item
    News.create!(
      title: "Aggiornamento FAQ",
      content: domanda.to_s,
      category: "FAQ",
      icon_class: "fas fa-pen",
      published_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error("[FAQ] Impossibile creare news aggiornamento per FAQ ##{id}: #{e.class} #{e.message}")
  end
end
  
