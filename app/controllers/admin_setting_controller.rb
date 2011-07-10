class AdminSettingController < ApplicationController
  before_filter :authenticate_admin!
  def edit
    @settings = Setting.admin.data
    puts @settings.inspect
  end

  def update
    @settings = Setting.admin
    puts params[:setting]
    @settings.data.merge!(params[:setting])
    @settings.save
    flash[:notice] = 'Setting was successfully created.'
    render :show
  end
  
  private
  
  def authenticate_admin!
    authenticate_user! unless user_signed_in?
    unless current_user.admin?
      render :text => 'Not found', :status => 404
    end
  end
end
