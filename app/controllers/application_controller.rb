class ApplicationController < ActionController::Base

  before_filter :authenticate_user!, :log_ip_address, :find_last_trade

  # protect_from_forgery
  prepend_before_filter :verify_authenticity_token_unless_api
  
  def verify_authenticity_token_unless_api
    verify_authenticity_token unless api?
  end 
  
  def log_ip_address
    Host.find_or_create_by_ip_address_and_user_id(request.remote_ip, current_user.id) if current_user
  end
  
  def api?
    puts params.inspect
    params['token'] && params['secret']
  end
  
  def find_last_trade
    @last_trade = Trade.last
  end
  
  def after_sign_in_path_for(resource)
    current_user.admin? ? admin_root_url : welcome_index_url
  end
  
  def authenticate_user!
    if api?
      authenticate_api_user!
    else
      super
      flash[:alert] = "The account has not been confirmed yet. Please check your email to find confirmation instructions." if current_user && !current_user.confirmed?
    end
  end
  
  def authenticate_api_user!
    params = request.params
    if params['token'] && params['secret']
      @current_user = User.find_by_token(params['token'])
      head 401 unless @current_user && @current_user.secret == params['secret']
    else
      head 401
    end
  end
  
  
  def authorised_block(model, &block)
    if model.user_id == current_user.id
      yield
    else
      model.errors.add(:base, 'You are not authorized for this action')
    end
  end
end
