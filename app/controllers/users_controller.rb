class UsersController < ApplicationController
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

      redirect_to login_path, notice: "Registrazione completata con successo!"
    else
      render :new
    end
  end
  
  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :registration_date, :terms_accepted, :role)
  end
end
