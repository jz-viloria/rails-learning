class ApplicationController < ActionController::Base
  # This is the base controller that all other controllers inherit from
  
  # Protect from CSRF attacks
  protect_from_forgery with: :exception
  
  # Helper methods available to all controllers
  helper_method :current_cart, :current_user, :logged_in?
  
  private
  
  def current_cart
    # Simple cart implementation using session
    @current_cart ||= session[:cart] || []
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    nil
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_login
    redirect_to login_path, alert: 'Please log in to access this page' unless logged_in?
  end
end
