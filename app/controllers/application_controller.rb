class ApplicationController < ActionController::Base
  before_filter :authenticate_user!, :log_ip_address, :find_last_trade

  protect_from_forgery
  
  def log_ip_address
    Host.find_or_create_by_ip_address_and_user_id(request.remote_ip, current_user.id) if current_user
  end
  
  def find_last_trade
    @last_trade = Trade.last
  end
  
  def after_sign_in_path_for(resource)
    current_user.admin? ? admin_root_url : welcome_index_url
  end
  
  def authenticate_user!
    super
    flash[:alert] = "The account has not been confirmed yet. Please check your email to find confirmation instructions." if current_user && !current_user.confirmed?
  end
end
