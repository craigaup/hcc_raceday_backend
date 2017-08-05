class Api::V2017::SessionController < Api::V2017::ApplicationController
  def login
    authorized_user = User.authenticate(user_params[:username],user_params[:login_password])
    if authorized_user
      session[:user_id] = authorized_user.id
      render json: {
        message: "You have logged in as #{authorized_user.username}"}, 
        status: 200,
        location: "home"
    else
      render json: {message: "Invalid Username or Password"},
        status: 401,
        location: "login"
    end
  end

  def logout
    session[:user_id] = nil
    byebug
    render json: {message: "Logged out"}, status: :loggedout,
      location: 'login'
  end

  private
  def user_params
    params.permit(:username,:login_password)
  end
end
