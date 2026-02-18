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

  def faq_suggestion_status_label(status)
    case status&.to_s
    when "attesa" then "In attesa"
    when "accettata" then "Accettata"
    when "rifiutata" then "Rifiutata"
    else status.to_s
    end
  end
end
