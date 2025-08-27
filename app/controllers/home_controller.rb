class HomeController < ApplicationController
  def index
  end

  def profilo
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

  def supporto
  end
end
