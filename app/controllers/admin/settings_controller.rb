module Admin
  class SettingsController < ::Admin::BaseController

    def edit
      @settings = Setting.admin.data
    end

    def update
      @settings = Setting.admin
      @settings.data.merge!(params[:setting])
      @settings.save
      flash[:notice] = 'Setting was successfully created.'
      render :action => :edit
    end
  end
end