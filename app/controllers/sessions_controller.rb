class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)

    if user&.authenticate(params[:password])
      # Login OK → salva id utente in sessione
      session[:user_id] = user.id

      if params[:remember_me] == "1"
        cookies.permanent.signed[:user_id] = user.id
      else
        cookies.delete(:user_id)
      end

      redirect_to root_path, notice: "Benvenuto, #{user.first_name}!"
    else
      flash.now[:alert] = "Email o password non validi"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    cookies.delete(:user_id)
    session[:user_id] = nil # Rimuove l'ID utente dalla sessione
    redirect_to root_path, notice: "Ti sei disconnesso con successo!"
  end
end
