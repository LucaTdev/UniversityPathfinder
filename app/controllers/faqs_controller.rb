class FaqsController < ApplicationController
  before_action :set_faq_locale, only: %i[admin user visitor create update destroy]

  def new
    @faq = Faq.new
  end

  def admin
    @faq = Faq.new
    @faqs = Faq.includes(:faq_translations).all.order(created_at: :desc)
    @faq_votes_up_map, @faq_votes_down_map, @faq_votes_current_map = compute_vote_maps(@faqs)
    @pending_faq_suggestions = FaqSuggestion.attesa.order(created_at: :desc)
  end

  def user
    @faqs = Faq.includes(:faq_translations).all.order(created_at: :desc)
    @faq_votes_up_map, @faq_votes_down_map, @faq_votes_current_map = compute_vote_maps(@faqs)
    @my_faq_suggestions =
      if current_user
        current_user.faq_suggestions.order(created_at: :desc)
      else
        []
      end
  end

  def visitor
    @faqs = Faq.includes(:faq_translations).all.order(created_at: :desc)
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

    categoria = faq_params[:categoria].to_s.strip
    @faq.update!(categoria: categoria) if categoria.present?
  end

  def faq_params
    params.require(:faq).permit(:domanda, :risposta, :categoria)
  end
end
