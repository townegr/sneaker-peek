class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    if user_id = session[:user_id] || User.where(name: params[:user_name]).pluck(:id)
      @current_user ||= User.find_by_id user_id
    end
  end
  helper_method :current_user
end
