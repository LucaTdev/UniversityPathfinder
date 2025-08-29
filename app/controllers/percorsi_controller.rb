class PercorsiController < ApplicationController
  protect_from_forgery with: :null_session # (solo per API senza form)

  def create
    percorso = Percorsi.new(percorso_params)

    if percorso.save
      render json: { status: 'ok', percorso: percorso }, status: :created
    else
      render json: { status: 'error', errors: percorso.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def percorso_params
    params.permit(:partenza, :arrivo)
  end
end
