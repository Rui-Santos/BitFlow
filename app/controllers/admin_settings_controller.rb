class AdminSettingsController < ApplicationController
  before_filter :authenticate_admin!
  
  def show
    @settings = Setting.admin.data
  end

  def update
    puts params.inspect
    setting = Setting.admin
    setting.data.merge!(params[:setting])
    setting.save
    
    puts setting.inspect
    render :show
  end
  
  private
  
  def authenticate_admin!
    unless current_user.admin?
      render :text => 'Not found', :status => 404
    end
  end
end
