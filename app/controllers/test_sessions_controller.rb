class TestSessionsController < ApplicationController
  def create
    raise ActionController::RoutingError, "Not Found" unless Rails.env.test?

    user = User.find(params[:user_id])
    sign_in(user)

    redirect_to params[:redirect_to].presence || root_path
  end
end
