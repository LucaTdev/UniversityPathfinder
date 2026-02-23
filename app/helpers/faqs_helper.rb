module FaqsHelper
  def faq_categories(faqs)
    Array(faqs)
      .map(&:categoria)
      .compact
      .map { |c| c.to_s.strip }
      .reject(&:blank?)
      .uniq
      .sort
  end

  def normalize_faq_locale(raw)
    raw.to_s.strip.tr("_", "-").downcase
  end

  def faq_locale_label(raw_locale)
    code = normalize_faq_locale(raw_locale)
    base = code.split("-").first

    labels = {
      "it" => "Italiano",
      "en" => "English",
      "fr" => "Français",
      "es" => "Español",
      "de" => "Deutsch",
      "pt" => "Português",
      "pt-br" => "Português (Brasil)"
    }

    labels[code].presence || labels[base].presence || code.upcase
  end

  def faq_locale_options
    locales = []
    locales.concat(Array(I18n.available_locales).map(&:to_s))
    locales << I18n.default_locale.to_s if I18n.respond_to?(:default_locale)
    locales.concat(extract_locales_from_i18n_load_path)
    locales << Faq::BASE_LOCALE.to_s
    locales << "en"

    begin
      locales.concat(FaqTranslation.distinct.pluck(:locale))
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
      # ignore (e.g., during assets precompile / missing DB)
    end

    normalized = locales.map { |l| normalize_faq_locale(l) }.reject(&:blank?).uniq

    base = Faq::BASE_LOCALE.to_s
    normalized.delete(base)
    normalized.delete("en")

    ordered = [base, "en"] + normalized.sort_by { |code| faq_locale_label(code).downcase }
    ordered.uniq.map { |code| [faq_locale_label(code), code] }
  end

  def extract_locales_from_i18n_load_path
    Array(I18n.load_path).filter_map do |path|
      base = File.basename(path.to_s)
      match = base.match(/(?:^|\.)([a-z]{2,3}(?:-[A-Za-z0-9]+)*)\.(?:yml|yaml|rb)\z/)
      match&.[](1)
    end
  rescue
    []
  end

  def faq_suggestion_status_label(status)
    case status&.to_s
    when "attesa" then "In attesa"
    when "accettata" then "Accettata"
    when "rifiutata" then "Rifiutata"
    else status.to_s
    end
  end
end
