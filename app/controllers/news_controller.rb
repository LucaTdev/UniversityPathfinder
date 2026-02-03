class NewsController < ApplicationController
  
  include NewsHelper  # <-- Aggiungi questa riga
  before_action :log_request
  before_action :authenticate_user!
  before_action :authorize_admin!, only: [:create, :update, :destroy]
  before_action :set_news, only: [:update, :destroy]

  def index
    @news = News.order(published_at: :desc).limit(10)
    render json: { news: @news }
  end
  
  def create
    @news = News.new(news_params)
    @news.published_at = Time.current
    
    if @news.save
      html = render_to_string(
        partial: 'news/news_item',
        locals: { news: @news },
        formats: [:html]
      )
      render json: { success: true, news: html }, status: :created
    else
      render json: { 
        success: false, 
        errors: @news.errors.full_messages 
      }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Errore in create: #{e.message}"
    render json: { 
      success: false, 
      errors: [e.message] 
    }, status: :internal_server_error
  end
  
  def update
    if @news.update(news_params)
      html = render_to_string(
        partial: 'news/news_item',
        locals: { news: @news },
        formats: [:html]
      )
      render json: { success: true, news: html }
    else
      render json: { 
        success: false, 
        errors: @news.errors.full_messages 
      }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Errore in update: #{e.message}"
    render json: { 
      success: false, 
      errors: [e.message] 
    }, status: :internal_server_error
  end
  
  def destroy
    @news.destroy
    render json: { success: true }
  rescue => e
    Rails.logger.error "Errore in destroy: #{e.message}"
    render json: { 
      success: false, 
      errors: [e.message] 
    }, status: :internal_server_error
  end
  
  private
  
  def set_news
    @news = News.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { 
      success: false, 
      errors: ['News non trovata'] 
    }, status: :not_found
  end
  
  def news_params
    params.require(:news).permit(:title, :content, :category, :icon_class)
  end

  private
  
  def authorize_admin!
    unless current_user&.admin?
      Rails.logger.warn "Tentativo non autorizzato da user_id: #{current_user&.id}, role: #{current_user&.role}"
      render json: { 
        success: false, 
        errors: ['Non hai i permessi per eseguire questa azione. Solo gli admin possono modificare le news.'] 
      }, status: :forbidden
      return false
    end
  end

  def log_request
    Rails.logger.info "=== NEWS CONTROLLER REQUEST ==="
    Rails.logger.info "Action: #{action_name}"
    Rails.logger.info "Current user: #{current_user&.id}"
    Rails.logger.info "Is admin: #{current_user&.admin?}"
  end

end