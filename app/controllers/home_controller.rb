class HomeController < ApplicationController
  before_filter :authenticate_user!, :log_ip_address
  def index
    
  end
end
