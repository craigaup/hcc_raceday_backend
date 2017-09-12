class Api::V2017::ApplicationController < ApplicationController
  after_filter :set_access_control_headers

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

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
