class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user!, only: [:show, :edit, :update, :destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    # Imposta il ruolo in base alla selezione
    case params[:user][:role]
    when "1" # studente
      @user.role = User::ROLE_STUDENT
    when "2" # admin
      @user.role = User::ROLE_ADMIN
    else
      @user.role = User::ROLE_BASE
    end

    if @user.save
      # Gestione profilo studente (SOLO se i campi sono compilati)
      if @user.student?
        student_id = params[:user][:student_id]
        university = params[:user][:university]
        
        # Crea il profilo studente solo se almeno uno dei campi è presente
        if student_id.present? || university.present?
          StudentProfile.create(
            user: @user,
            student_id: student_id,
            university: university
          )
        end
      
      # Gestione profilo admin (SOLO se il token è presente)
      elsif @user.admin?
        admin_token = params[:user][:admin_token]
        
        if admin_token.present?
          # Verifica il token solo se è stato inserito
          if admin_token == "1234"
            AdminProfile.create(user: @user, token: admin_token)
          else
            @user.errors.add(:base, "Token amministratore non valido")
            @user.destroy
            render :new, status: :unprocessable_entity and return
          end
        end
      end

      redirect_to login_path, notice: "Registrazione completata con successo!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: user_profile_json }
    end
  end

  def edit
  end

  def update
    if @user.update(user_update_params)
      respond_to do |format|
        format.html { redirect_to @user, notice: 'Profilo aggiornato con successo!' }
        format.json { render json: user_profile_json }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
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

  def profile
    @user = current_user
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
    redirect_to root_path unless current_user&.id == @user.id || current_user&.admin?
  end

  def user_params
    # IMPORTANTE: Rimuovi student_id, university e admin_token da qui
    # perché NON sono campi della tabella users
    params.require(:user).permit(
      :first_name, 
      :last_name, 
      :email, 
      :password, 
      :password_confirmation, 
      :registration_date, 
      :terms_accepted, 
      :role
    )
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