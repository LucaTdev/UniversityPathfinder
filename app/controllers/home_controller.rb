class HomeController < ApplicationController
  before_action :require_login, only: [:profilo, :mappa, :sedi]
  def index
  end

  def profilo
    @user = current_user
    @recent_routes = @user.routes.recent.limit(5)
  end

  def sedi
    @user_role = current_user&.role || 0 # Se non loggato, role = 0 (guest)
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
  
end