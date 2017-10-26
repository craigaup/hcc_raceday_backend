class SessionsController < ApplicationController
  before_filter :authenticate_user, :only => [:change_password, 
                                              :change_password_attempt]
  before_filter :save_login_state, :only => [:login, :login_attempt]

  def login
  end

  def login_attempt
    authorized_user = User.authenticate(params[:username],params[:login_password])
    if authorized_user
      session[:user_id] = authorized_user.id
      flash[:notice] = "You have logged in as #{authorized_user.username}"
      redirect_to(:action => 'overview', :controller => 'checkpoint')
    else
      flash[:notice] = "Invalid Username or Password"
      flash[:color]= "invalid"
      render "login"
    end
  end

  def change_password
  end

  def change_password_attempt
    inf = params.permit(:login_password, :new_password,
                        :password_confirmation)
    authorized_user = User.authenticate(@current_user.username,
                                        inf[:login_password])

    unless authorized_user
      flash[:notice] = "Passwords don't match!"
      flash[:color]= "invalid"
      render "change_password"
      return
    end

    @current_user.password = inf[:new_password]
    @current_user.password_confirmation = inf[:password_confirmation]
    unless @current_user.save
      flash[:notice] = "Passwords don't match"
      flash[:color]= "invalid"
      render "change_password"
      return
    end

    flash[:notice] = "Success"
    redirect_to(:action => 'overview', :controller => 'checkpoint')
  end

  def logout
    session[:user_id] = nil
    redirect_to :action => 'login'
  end
end
