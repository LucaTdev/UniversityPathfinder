class FaqsController < ApplicationController
  def new
    @faq = Faq.new
  end

  def create
    @faq = Faq.new(faq_params)
    if @faq.save
      redirect_to home_supporto_path, notice: "FAQ aggiunta"
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
      redirect_to home_supporto_path, notice: "FAQ aggiornata con successo."
    else
      flash.now[:alert] = "Errore aggiornamento della FAQ."
      render :edit
    end
  end

  def destroy
    @faq = Faq.find(params[:id])
    @faq.destroy
    redirect_to home_supporto_path, notice: "FAQ eliminata con successo."
  end

  private

  def faq_params
    params.require(:faq).permit(:domanda, :risposta, :categoria)
  end
end
