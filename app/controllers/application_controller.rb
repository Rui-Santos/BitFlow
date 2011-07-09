class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def log_ip_address
    Host.find_or_create_by_ip_address_and_user_id(request.remote_ip, current_user.id)
  end
end
