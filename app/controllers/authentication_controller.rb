class AuthenticationController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]
  before_action :require_login, only: [:logout, :dashboard]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    
    if @user.save
      session[:user_id] = @user.id
      @user.update_last_login!
      redirect_to dashboard_path, notice: 'Account created successfully! Welcome to our store!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def login
    @user = User.new
  end
  
  def authenticate
    user = User.find_by(email: params[:email]&.downcase)
    
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      user.update_last_login!
      redirect_to dashboard_path, notice: 'Welcome back!'
    else
      @user = User.new(email: params[:email])
      flash.now[:alert] = 'Invalid email or password'
      render :login, status: :unprocessable_entity
    end
  end
  
  def logout
    session[:user_id] = nil
    redirect_to root_path, notice: 'You have been logged out successfully'
  end
  
  def dashboard
    @user = current_user
    @recent_orders = @user.recent_orders(5)
    @total_spent = @user.total_spent
    @order_count = @user.order_count
  end
  
  private
  
  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :phone, :password, :password_confirmation,
      :address_line1, :address_line2, :city, :state, :zip_code, :country,
      :email_notifications, :sms_notifications
    )
  end
  
  def redirect_if_logged_in
    redirect_to dashboard_path if logged_in?
  end
  
  def require_login
    redirect_to login_path, alert: 'Please log in to access this page' unless logged_in?
  end
end
