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
    current_user.admin? ? admin_root_url : (stored_location_for(resource) || welcome_index_url)
  end
end
