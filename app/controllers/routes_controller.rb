class RoutesController < ApplicationController
  before_action :require_login

  def create
    @route = current_user.routes.build(route_params)
    @route.searched_at = Time.current

    if @route.save
      render json: { 
        success: true, 
        message: 'Ricerca salvata',
        routes_count: current_user.routes_count
      }, status: :created
    else
      render json: { 
        success: false, 
        errors: @route.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def stats
    # Restituisce il conteggio delle rotte dell'utente corrente
    # Uso .count o il metodo routes_count se lo hai definito nel modello User
    render json: { 
      routes_count: current_user.routes.count 
    }
  end

  private

  def route_params
    params.require(:route).permit(:destination, :destination_name)
  end
end