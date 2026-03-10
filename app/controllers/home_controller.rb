class HomeController < ApplicationController
  before_action :require_login, only: [:profilo, :mappa, :sedi]
  def index
  end

  def profilo
    @user = current_user
    @recent_routes = @user.routes.recent.limit(5)
    @favorite_routes = @user.top_favorite_routes

    if @user&.admin?
      @pending_faq_suggestions_count = FaqSuggestion.attesa.count
      @pending_faq_suggestions = FaqSuggestion.attesa.order(created_at: :desc).limit(10)
    else
      @pending_faq_suggestions_count = 0
      @pending_faq_suggestions = []
    end
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
    scope = News.order(published_at: :desc)
    scope = scope.where.not(category: "FAQ") if current_user && !current_user.faq_notifications_enabled?
    @news = scope.limit(10)
  end
  
  def faqs
    #@faqs = Faqs.all
  end
end
