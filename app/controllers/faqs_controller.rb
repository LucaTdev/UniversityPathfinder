class FaqsController < ApplicationController
  def new
    @faq = Faq.new
  end

  def admin
    @faq = Faq.new
    @faqs = Faq.all.order(created_at: :desc)
    @faq_votes_up_map, @faq_votes_down_map, @faq_votes_current_map = compute_vote_maps(@faqs)
    @pending_faq_suggestions = FaqSuggestion.attesa.order(created_at: :desc)
  end

  def user
    @faqs = Faq.all.order(created_at: :desc)
    @faq_votes_up_map, @faq_votes_down_map, @faq_votes_current_map = compute_vote_maps(@faqs)
    @my_faq_suggestions =
      if current_user
        current_user.faq_suggestions.order(created_at: :desc)
      else
        []
      end
  end

  def visitor
    @faqs = Faq.all.order(created_at: :desc)
    @faq_votes_up_map, @faq_votes_down_map, @faq_votes_current_map = compute_vote_maps(@faqs)
  end
  
  def create
    @faq = Faq.new(faq_params)
    if @faq.save
      redirect_to admin_faqs_path, notice: "FAQ aggiunta"
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
    if @faq.update(faq_params)
      redirect_to admin_faqs_path, notice: "FAQ aggiornata con successo."
    else
      flash.now[:alert] = "Errore aggiornamento della FAQ."
      render :edit
    end
  end

  def destroy
    @faq = Faq.find(params[:id])
    @faq.destroy
    redirect_to admin_faqs_path, notice: "FAQ eliminata con successo."
  end

  private

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

  def faq_params
    params.require(:faq).permit(:domanda, :risposta, :categoria)
  end
end
