class ApplicationController < ActionController::Base
  before_filter :authenticate_user!, :log_ip_address

  protect_from_forgery
  def log_ip_address
    Host.find_or_create_by_ip_address_and_user_id(request.remote_ip, current_user.id) if current_user
  end
end
