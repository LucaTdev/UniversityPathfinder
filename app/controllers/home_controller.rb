class HomeController < ApplicationController
  before_action :require_login, only: [:profilo, :mappa, :sedi]
  def index
  end

  def profilo
    @user = current_user
  end

  def sedi
    @user_role = current_user&.role || 0 # Se non loggato, role = 0 (guest)
  end 

  def mappa
    @sedi = Sede.all
  end
  
  def login
  end
  
  def do_login
    if params[:username].present?
      session[:session] = params[:username]
      redirect_to "/profilo"
    else
      flash[:alert] = "inserisci un nome utente"
      redirect_to "profilo"
    end
  end

  def logout
    reset_session
    redirect_to root_path
  end

  def registrazione
  end

  def meteo
  end
  
end