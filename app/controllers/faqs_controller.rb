class FaqsController < ApplicationController
  before_action :require_login, only: %i[admin user create update destroy]
  before_action :authorize_admin!, only: %i[admin create update destroy]
  before_action :authorize_user!, only: %i[user]

  before_action :set_faq_locale, only: %i[admin user visitor create update destroy]
  before_action :set_faq_categories, only: %i[admin user visitor]

  def new
    @faq = Faq.new
  end

  def admin
    @faq = Faq.new
    @faqs = apply_search(Faq.includes(:faq_translations).order(created_at: :desc))
    @faq_votes_up_map, @faq_votes_down_map, @faq_votes_current_map = compute_vote_maps(@faqs)
    @pending_faq_suggestions = FaqSuggestion.attesa.order(created_at: :desc)
  end

  def user
    @faqs = apply_search(Faq.includes(:faq_translations).order(created_at: :desc))
    @faq_votes_up_map, @faq_votes_down_map, @faq_votes_current_map = compute_vote_maps(@faqs)
    @my_faq_suggestions =
      if current_user
        current_user.faq_suggestions.order(created_at: :desc)
      else
        []
      end
  end

  def visitor
    @faqs = apply_search(Faq.includes(:faq_translations).order(created_at: :desc))
    @faq_votes_up_map, @faq_votes_down_map, @faq_votes_current_map = compute_vote_maps(@faqs)
  end
  
  def create
    @faq = Faq.new(faq_params)
    if @faq.save
      redirect_to admin_faqs_path(locale: @faq_locale), notice: "FAQ aggiunta"
    else
      flash.now[:alert] = "Errore aggiunta della FAQ."
      render :new
    end
  end

  def edit
    @faq = Faq.find(params[:id])
  end

  def update
    @faq = Faq.find(params[:id])

    if updating_translation?
      update_translation!
      return redirect_to admin_faqs_path(locale: @faq_locale), notice: "Traduzione aggiornata con successo."
    end

    if @faq.update(faq_params)
      redirect_to admin_faqs_path(locale: @faq_locale), notice: "FAQ aggiornata con successo."
    else
      flash.now[:alert] = "Errore aggiornamento della FAQ."
      render :edit
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to admin_faqs_path(locale: @faq_locale), alert: "Errore aggiornamento della traduzione."
  end

  def destroy
    @faq = Faq.find(params[:id])
    @faq.destroy
    redirect_to admin_faqs_path(locale: @faq_locale), notice: "FAQ eliminata con successo."
  end

  private

  def authorize_user!
    return unless current_user&.admin?
    redirect_to admin_faqs_path, alert: "Non hai i permessi per accedere a questa pagina"
  end

  def set_faq_locale
    @faq_locale = normalize_faq_locale(params[:faq_locale].presence || params[:locale].presence || session[:faq_locale].presence)
    session[:faq_locale] = @faq_locale if @faq_locale.present?
  end

  def compute_vote_maps(faqs)
    ids = Array(faqs).map(&:id)
    return [{}, {}, {}] if ids.empty?

    up_map = FaqVote.where(faq_id: ids, value: 1).group(:faq_id).count
    down_map = FaqVote.where(faq_id: ids, value: -1).group(:faq_id).count

    current_map = {}
    if current_user
      current_map = FaqVote.where(faq_id: ids, user_id: current_user.id).pluck(:faq_id, :value).to_h
    end

    [up_map, down_map, current_map]
  end

  def apply_search(scope)
    raw_query = params[:q].to_s
    @faq_query = raw_query.strip
    return scope if @faq_query.blank?

    query_terms = @faq_query.split(/\s+/).reject(&:blank?)
    return scope if query_terms.empty?

    normalized_locale = normalize_faq_locale(@faq_locale)
    base_locale = Faq::BASE_LOCALE.to_s
    locale_base = normalized_locale.to_s.split("-").first

    query_terms.reduce(scope) do |rel, term|
      pattern = "%#{ActiveRecord::Base.sanitize_sql_like(term)}%"

      base_match = <<~SQL.squish
        faqs.domanda ILIKE :pattern
        OR faqs.risposta ILIKE :pattern
        OR faqs.categoria ILIKE :pattern
      SQL

      if locale_base.blank? || locale_base == base_locale
        rel.where(base_match, pattern: pattern)
      else
        rel = rel.left_joins(:faq_translations).distinct

        locale_sql, locale_binds = translation_locale_predicate(normalized_locale)
        translated_match = <<~SQL.squish
          (#{locale_sql})
          AND (
            faq_translations.domanda ILIKE :pattern
            OR faq_translations.risposta ILIKE :pattern
          )
        SQL

        rel.where("(#{base_match}) OR (#{translated_match})", { pattern: pattern, **locale_binds })
      end
    end
  end

  def translation_locale_predicate(normalized_locale)
    loc = normalized_locale.to_s
    return ["1=0", {}] if loc.blank?

    base = loc.split("-").first

    if loc.include?("-")
      ["faq_translations.locale = :loc OR faq_translations.locale = :base", { loc: loc, base: base }]
    else
      ["faq_translations.locale = :loc OR faq_translations.locale LIKE :prefix", { loc: loc, prefix: "#{loc}-%" }]
    end
  end

  def normalize_faq_locale(raw)
    value = raw.to_s.strip.tr("_", "-").downcase
    value.presence || Faq::BASE_LOCALE.to_s
  end

  def updating_translation?
    base = @faq_locale.to_s.split("-").first
    base.present? && base != Faq::BASE_LOCALE.to_s
  end

  def update_translation!
    attrs = faq_params.slice(:domanda, :risposta)
    translation =
      @faq.faq_translations.to_a.find { |t| normalize_faq_locale(t.locale) == @faq_locale } ||
        @faq.faq_translations.build(locale: @faq_locale)

    translation.assign_attributes(attrs)
    translation.save!

    if faq_params[:faq_category_id].present?
      @faq.update!(faq_category_id: faq_params[:faq_category_id])
    else
      categoria = faq_params[:categoria].to_s.strip
      @faq.update!(categoria: categoria) if categoria.present?
    end
  end

  def faq_params
    params.require(:faq).permit(:domanda, :risposta, :categoria, :faq_category_id)
  end

  def set_faq_categories
    FaqCategory.general!
    @faq_categories = FaqCategory
      .order(Arel.sql("CASE WHEN lower(name) = '#{FaqCategory::GENERAL_NAME.downcase}' THEN 0 ELSE 1 END"))
      .order(Arel.sql("lower(name)"))
  end
end
