module Admin
  class FaqSuggestionsController < ApplicationController
    before_action :require_login
    before_action :authorize_admin!
    before_action :set_suggestion

    def publish
      ActiveRecord::Base.transaction do
        faq = Faq.create!(
          domanda: publish_params[:domanda],
          risposta: publish_params[:risposta],
          categoria: publish_params[:categoria]
        )

        @suggestion.update!(
          domanda: publish_params[:domanda],
          categoria: publish_params[:categoria],
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
