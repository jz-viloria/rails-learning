class ApplicationController < ActionController::Base
  # This is the base controller that all other controllers inherit from
  
  # Protect from CSRF attacks
  protect_from_forgery with: :exception
  
  # Helper methods available to all controllers
  helper_method :current_cart
  
  private
  
  def current_cart
    # Simple cart implementation using session
    @current_cart ||= session[:cart] || []
  end
end
