class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s.downcase)

    if user&.authenticate(params[:password])
      session.delete(:oauth_registration)
      sign_in(user, remember: params[:remember_me] == "1")
      redirect_to root_path, notice: "Benvenuto, #{user.first_name}!"
    else
      flash.now[:alert] = "Email o password non validi"
      render :new, status: :unprocessable_entity
    end
  end

  def omniauth
    auth = request.env["omniauth.auth"]

    unless oauth_email_verified?(auth)
      session.delete(:oauth_registration)
      redirect_to login_path, alert: "Google non ha restituito un'email verificata."
      return
    end

    email = auth.dig("info", "email").to_s.downcase
    user = User.find_by(email: email)

    if user
      session.delete(:oauth_registration)
      sign_in(user)
      redirect_to root_path, notice: "Accesso effettuato con Google."
      return
    end

    session[:oauth_registration] = oauth_registration_payload(auth)
    redirect_to oauth_registration_path, notice: "Completa la registrazione per continuare."
  end

  def omniauth_failure
    session.delete(:oauth_registration)
    redirect_to login_path, alert: "Autenticazione Google non riuscita."
  end

  def destroy
    sign_out
    session.delete(:oauth_registration)
    redirect_to root_path, notice: "Ti sei disconnesso con successo!"
  end

  private

  def oauth_email_verified?(auth)
    email = auth&.dig("info", "email").presence
    verified = auth&.dig("info", "email_verified")
    verified = auth&.dig("extra", "raw_info", "email_verified") if verified.nil?

    email.present? && ActiveModel::Type::Boolean.new.cast(verified)
  end

  def oauth_registration_payload(auth)
    info = auth.fetch("info", {})
    first_name = info["first_name"].presence
    last_name = info["last_name"].presence

    if first_name.blank? || last_name.blank?
      inferred_first_name, inferred_last_name = info["name"].to_s.split(/\s+/, 2)
      first_name = inferred_first_name if first_name.blank?
      last_name = inferred_last_name if last_name.blank?
    end

    {
      "provider" => auth["provider"].to_s,
      "uid" => auth["uid"].to_s,
      "email" => info["email"].to_s.downcase,
      "first_name" => first_name.to_s,
      "last_name" => last_name.to_s
    }
  end
end
