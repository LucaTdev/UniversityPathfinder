class SediController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_sede, only: [:show, :update, :destroy]

  # GET /sedi
  def index
    render json: Sede.all
  end

  # GET /sedi/:id
  def show
    render json: @sede
  end

  # POST /sedi
  def create
    @sede = Sede.new(sede_params)
    if @sede.save
      render json: @sede, status: :created
    else
      render json: { errors: @sede.errors.full_messages }, status: :unprocessable_entity
    end
  end


  # PUT /sedi/:id
  def update
    if @sede.update(sede_params)
      render json: @sede, status: :ok
    else
      render json: { errors: @sede.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /sedi/:id
  def destroy
    @sede.destroy
    head :no_content
  end

  private

  def set_sede
    @sede = Sede.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Sede non trovata" }, status: :not_found
  end

  def sede_params
    params.require(:sede).permit(:nome, :indirizzo, edifici: [])
  end

end

