class Api::V2017::ApplicationController < ApplicationController
  protected
  def authenticate_user
    if session[:user_id]
      # set current user object to @current_user object variable
      @current_user = User.find session[:user_id] 
      if @current_user 
        return true	
      end
    end
    render json: {message: 'Not logged in'}, status: 401,
      location: 'login'
    return false
  end
end
