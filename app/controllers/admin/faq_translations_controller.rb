module Admin
  class FaqTranslationsController < ApplicationController
    before_action :require_admin_json!
    before_action :set_faq

    def index
      translations =
        @faq.faq_translations
          .order(:locale)
          .map do |t|
            {
              id: t.id,
              locale: t.locale,
              domanda: t.domanda,
              risposta: t.risposta,
              updated_at: t.updated_at&.iso8601
            }
          end

      render json: {
        faq: {
          id: @faq.id,
          domanda: @faq.domanda.to_s,
          risposta: @faq.risposta.to_s
        },
        translations: translations
      }
    end

    # Upsert by locale (unique per FAQ)
    def create
      locale = normalize_locale(translation_params[:locale])
      return render json: { error: "invalid_locale" }, status: :unprocessable_entity if locale.blank?

      translation = @faq.faq_translations.where("lower(locale) = ?", locale.downcase).first ||
        @faq.faq_translations.build(locale: locale)

      translation.domanda = translation_params[:domanda]
      translation.risposta = translation_params[:risposta]

      if translation.save
        render json: {
          translation: {
            id: translation.id,
            locale: translation.locale,
            domanda: translation.domanda,
            risposta: translation.risposta,
            updated_at: translation.updated_at&.iso8601
          }
        }
      else
        render json: { error: "invalid", messages: translation.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      translation = @faq.faq_translations.find(params[:id])
      translation.destroy!
      render json: { ok: true }
    rescue ActiveRecord::RecordNotFound
      render json: { error: "not_found" }, status: :not_found
    rescue ActiveRecord::RecordNotDestroyed
      render json: { error: "not_destroyed", messages: translation.errors.full_messages }, status: :unprocessable_entity
    end

    private

    def require_admin_json!
      return if logged_in? && current_user&.admin?

      if logged_in?
        render json: { error: "forbidden" }, status: :forbidden
      else
        render json: { error: "unauthorized", login_url: login_path }, status: :unauthorized
      end
    end

    def set_faq
      @faq = Faq.find(params[:faq_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "faq_not_found" }, status: :not_found
    end

    def translation_params
      params.require(:faq_translation).permit(:locale, :domanda, :risposta)
    end

    def normalize_locale(raw)
      raw.to_s.strip.tr("_", "-").downcase
    end
  end
end

