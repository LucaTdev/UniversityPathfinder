class FaqSuggestionsController < ApplicationController
  before_action :require_login

  def create
    if current_user.faq_suggestions.attesa.count >= 3
      return redirect_to user_faqs_path, alert: "Hai già 3 suggerimenti in attesa. Elimina un suggerimento o attendi la revisione."
    end

    suggestion = current_user.faq_suggestions.new(faq_suggestion_params)
    suggestion.save!

    redirect_to user_faqs_path, notice: "Suggerimento inviato. Grazie!"
  rescue ActiveRecord::RecordInvalid
    redirect_to user_faqs_path, alert: "Impossibile inviare il suggerimento."
  end

  def destroy
    suggestion = current_user.faq_suggestions.attesa.find(params[:id])
    suggestion.destroy!
    redirect_to user_faqs_path, notice: "Suggerimento eliminato."
  rescue ActiveRecord::RecordNotFound
    redirect_to user_faqs_path, alert: "Suggerimento non eliminabile."
  end

  private

  def faq_suggestion_params
    params.require(:faq_suggestion).permit(:domanda, :dettagli, :categoria, :risposta)
  end
end
