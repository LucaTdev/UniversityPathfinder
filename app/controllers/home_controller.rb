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
    @persona = Persona.new
    @persone = Persona.all.order(:id)  # ordina per id, puoi cambiare se vuoi
  end
end
