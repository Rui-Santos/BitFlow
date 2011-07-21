module Admin
  class BaseController < ApplicationController
    before_filter :authenticate_admin!

    private
    def authenticate_admin!
      authenticate_user! unless user_signed_in?
      unless current_user.admin?
        render :text => 'Not found', :status => 404
      end
    end
  end
end