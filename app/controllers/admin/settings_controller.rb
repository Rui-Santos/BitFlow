module Admin
  class SettingsController < ::Admin::BaseController
    def edit
      @settings = Setting.admin.data
    end

    def update
      @settings = Setting.admin
      @settings.data.merge!(parse_settings_from_request(params[:setting]))
      @settings.save
      flash[:notice] = 'Settings were successfully modified.'
      redirect_to :action => :edit
    end
    
    def parse_settings_from_request(setting_params)
      symbolized_values = {}
      setting_params.each do |k, v|
        symbolized_values[(k.to_sym rescue k)] = v.to_f
      end
      symbolized_values
    end
  end
end