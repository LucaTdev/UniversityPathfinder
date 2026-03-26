class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user!, only: [:show, :edit, :update, :destroy]
  before_action :set_oauth_registration, only: [:oauth_new, :oauth_create]
  before_action :ensure_oauth_registration!, only: [:oauth_new, :oauth_create]

  def new
    @user = User.new
  end

  def oauth_new
    @user = User.new(
      first_name: @oauth_registration["first_name"],
      last_name: @oauth_registration["last_name"],
      email: @oauth_registration["email"],
      role: User::ROLE_STUDENT
    )
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
          if admin_token == admin_registration_token
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

  def oauth_create
    existing_user = User.find_by(email: @oauth_registration["email"])

    if existing_user
      session.delete(:oauth_registration)
      sign_in(existing_user)
      redirect_to root_path, notice: "Accesso effettuato con Google."
      return
    end

    @user = User.new(oauth_account_params)
    @user.email = @oauth_registration["email"]
    @user.registration_date = Date.current

    generated_password = SecureRandom.base58(32)
    @user.password = generated_password
    @user.password_confirmation = generated_password

    assign_role_from_param(@user, oauth_account_params[:role])

    unless oauth_role_requirements_valid?
      render :oauth_new, status: :unprocessable_entity
      return
    end

    if @user.save
      if setup_oauth_role_profile(@user)
        session.delete(:oauth_registration)
        sign_in(@user)
        redirect_to root_path, notice: "Registrazione completata con Google!"
      else
        render :oauth_new, status: :unprocessable_entity
      end
    else
      render :oauth_new, status: :unprocessable_entity
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

  def oauth_account_params
    params.fetch(:user, ActionController::Parameters.new).permit(
      :first_name,
      :last_name,
      :terms_accepted,
      :role
    )
  end

  def oauth_profile_params
    params.fetch(:user, ActionController::Parameters.new).permit(
      :student_id,
      :university,
      :admin_token
    )
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

  def set_oauth_registration
    @oauth_registration = session[:oauth_registration]
  end

  def ensure_oauth_registration!
    return if @oauth_registration.present?

    redirect_to login_path, alert: "Avvia prima l'accesso con Google."
  end

  def assign_role_from_param(user, role_param)
    case role_param
    when "1"
      user.role = User::ROLE_STUDENT
    when "2"
      user.role = User::ROLE_ADMIN
    else
      user.role = User::ROLE_BASE
    end
  end

  def setup_oauth_role_profile(user)
    if user.student?
      student_id = oauth_profile_params[:student_id]
      university = oauth_profile_params[:university]

      if student_id.present? || university.present?
        StudentProfile.create(user: user, student_id: student_id, university: university)
      end

      return true
    end

    return true unless user.admin?

    AdminProfile.create(user: user, token: oauth_profile_params[:admin_token])
    true
  end

  def oauth_role_requirements_valid?
    return true unless @user.admin?

    admin_token = oauth_profile_params[:admin_token]

    if admin_token.blank?
      @user.errors.add(:admin_token, "è obbligatorio per gli amministratori")
      return false
    end

    if admin_token != admin_registration_token
      @user.errors.add(:base, "Token amministratore non valido")
      return false
    end

    true
  end

  def admin_registration_token
    ENV["ADMIN_REGISTRATION_TOKEN"].presence || "1234"
  end
end
