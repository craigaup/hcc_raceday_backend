class Api::V2017::SessionController < Api::V2017::ApplicationController
  before_action :authenticate_user,  only: [:change_password]

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
    render json: {message: "Logged out"}, status: 200,
      location: 'login'
  end

  def change_password
    inf = params.permit(:login_password, :new_password,
                                :password_confirmation)
    authorized_user = User.authenticate(@current_user,
                                        inf[:login_password])

    unless authorized_user
      render json: {message: "Invalid user or password"},
        status: 401,
        location: "change_password"
      return
    end

    @current_user.password = inf[:new_password]
    @current_user.password_confirmation = inf[:password_confirmation]
    unless @current_user.save
      render json: {message: @current_user.errors.messages}, status: 406,
        location: "change_password"
      return
    end

    render json: {message: 'Success'}, status: 200,
      location: "change_password"
  end
  private
  def user_params
    params.permit(:username,:login_password)
  end
end
