class HomeController < ApplicationController
  def index
  end

  def profilo
    @user = current_user # oppure User.find(params[:id]) se passi l’id
  end

  def sedi
  end 

  def mappa
    @sedi = Sede.all
  end
  
  def login
  end
  
  def registrazione
  end

  def meteo
  end
  
  def faqs
    #@faqs = Faqs.all
  end
end