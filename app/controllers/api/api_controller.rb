class ApiController < ActionController::Base
  before_filter :authenticate_api_user!

  def authenticate_api_user!
    params = request.params
    if params['token'] && params['secret']
      @current_user = User.find_by_token(params['token'])
      head 401 unless @current_user && @current_user.secret == params['secret']
    else
      head 401
    end
  end
end