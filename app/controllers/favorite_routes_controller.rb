class FavoriteRoutesController < ApplicationController
  before_action :require_login

  # POST /favorite_routes
  def create
    # Cerca se esiste già questo percorso
    existing = current_user.favorite_routes.find_by(
      start_location: favorite_route_params[:start_location],
      end_location: favorite_route_params[:end_location]
    )

    if existing
      # Se esiste, incrementa il contatore
      existing.increment_search!
      render json: {
        success: true,
        message: 'Percorso aggiornato nei preferiti',
        favorite_route: existing,
        favorites_count: current_user.favorites_count
      }
    else
      # Verifica se l'utente ha già 3 preferiti
      if current_user.favorite_routes.count >= 3
        # Rimuovi il meno usato
        least_used = current_user.favorite_routes.order(search_count: :asc).first
        least_used.destroy
      end

      # Crea il nuovo preferito
      @favorite_route = current_user.favorite_routes.build(favorite_route_params)

      if @favorite_route.save
        render json: {
          success: true,
          message: 'Percorso aggiunto ai preferiti nel tuo profilo!',
          favorite_route: @favorite_route,
          favorites_count: current_user.favorites_count
        }, status: :created
      else
        render json: {
          success: false,
          errors: @favorite_route.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @favorite_route = current_user.favorite_routes.find(params[:id])
    @favorite_route.destroy

    respond_to do |format|
      # Se la richiesta arriva da Turbo, invia l'istruzione per rimuovere l'elemento HTML
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@favorite_route) }
      
      # Manteniamo il JSON nel caso serva ad altre parti della tua app (es. chiamate fetch/axios)
      format.json { 
        render json: { 
          success: true, 
          message: 'Percorso rimosso dai preferiti', 
          favorites_count: current_user.favorites_count 
        } 
      }
      
      # Fallback classico
      format.html { redirect_back fallback_location: root_path, notice: 'Percorso rimosso' }
    end
  end

  private

  def favorite_route_params
    params.require(:favorite_route).permit(
      :start_location, :end_location, :start_name, :end_name,
      :distance_km, :duration_minutes, :transport_mode
    )
  end
end