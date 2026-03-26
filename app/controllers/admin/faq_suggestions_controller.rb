module Admin
  class FaqSuggestionsController < ApplicationController
    before_action :require_login
    before_action :authorize_admin!
    before_action :set_suggestion

    def publish
      ActiveRecord::Base.transaction do
        category_name = publish_params[:categoria].to_s.strip
        category =
          if category_name.present?
            FaqCategory.where("lower(name) = ?", category_name.downcase).first_or_create!(name: category_name)
          else
            FaqCategory.general!
          end

        faq = Faq.create!(
          domanda: publish_params[:domanda],
          risposta: publish_params[:risposta],
          faq_category: category
        )

        @suggestion.update!(
          domanda: publish_params[:domanda],
          categoria: category.name,
          faq_category: category,
          status: :accettata,
          faq: faq
        )
      end

      redirect_to admin_faqs_path, notice: "Suggerimento pubblicato come FAQ."
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_faqs_path, alert: "Impossibile pubblicare il suggerimento."
    end

    def reject
      @suggestion.update!(status: :rifiutata)
      redirect_to admin_faqs_path, notice: "Suggerimento rifiutato."
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_faqs_path, alert: "Impossibile rifiutare il suggerimento."
    end

    private

    def set_suggestion
      @suggestion = FaqSuggestion.find(params[:id])
    end

    def publish_params
      params.fetch(:publish, {}).permit(:categoria, :domanda, :risposta)
    end
  end
end
