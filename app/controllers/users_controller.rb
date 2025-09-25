class UsersController < ApplicationController

  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:show, :edit, :update, :destroy] # Assumendo che tu abbia un sistema di autenticazione
  before_action :authorize_user!, only: [:show, :edit, :update, :destroy]
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    case params[:user][:role]
    when "1" # studente
      @user.role = User::ROLE_STUDENT
    when "2" # admin
      @user.role = User::ROLE_ADMIN
    else
      @user.role = User::ROLE_BASE
    end

    if @user.save
      if @user.student?
        StudentProfile.create!(
          user: @user,
          student_id: params[:student_id],
          university: params[:university]
        )
      elsif @user.admin?
        if params[:admin_token] == "1234"
          AdminProfile.create!(user: @user, token: params[:admin_token])
        else
          @user.errors.add(:base, "Token amministratore non valido")
          @user.destroy
          render :new and return
        end
      end

      redirect_to sessions_new_path, notice: "Registrazione completata con successo!"
    else
      render :new
    end
  end

  def show
    # @user è già settato dal before_action
    respond_to do |format|
      format.html # Renderizza la vista HTML
      format.json { render json: user_profile_json }
    end
  end

  def edit
    # @user è già settato dal before_action
  end

  def update
    if @user.update(user_update_params)
      respond_to do |format|
        format.html { redirect_to @user, notice: 'Profilo aggiornato con successo!' }
        format.json { render json: user_profile_json }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Account eliminato con successo.' }
      format.json { head :no_content }
    end
  end

   # Action per ottenere il profilo dell'utente corrente
  def profile
    @user = current_user # Assumendo che tu abbia current_user helper
    respond_to do |format|
      format.html { render 'show' }
      format.json { render json: user_profile_json }
    end
  end
  
  private

  def set_user
    @user = User.find(params[:id])
  end

  def authenticate_user!
    # Implementa la tua logica di autenticazione
    # redirect_to login_path unless user_signed_in?
  end

  def authorize_user!
    # Verifica che l'utente possa accedere al profilo
    redirect_to root_path unless current_user&.id == @user.id || current_user&.admin?
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :registration_date, :terms_accepted, :role)
  end

  def user_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def user_profile_json
    {
      id: @user.id,
      first_name: @user.first_name,
      last_name: @user.last_name,
      full_name: @user.full_name,
      email: @user.email,
      role: @user.role,
      role_display: @user.role_display,
      registration_date: @user.registration_date,
      registration_year: @user.registration_year,
      registration_month_year: @user.registration_month_year,
      routes_count: @user.routes_count,
      favorites_count: @user.favorites_count,
      notifications_count: @user.notifications_count,
      created_at: @user.created_at,
      updated_at: @user.updated_at
    }
  end
end
