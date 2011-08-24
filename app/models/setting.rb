class Setting < ActiveRecord::Base
  serialize :data, Hash
  
  def self.admin
    setting = Setting.find_by_setting_type(:admin)
    if setting.nil?
      setting = Setting.create(:setting_type => :admin, :data => $default_admin_settings.dup) 
    end
    setting
  end
end