class Setting < ActiveRecord::Base
  serialize :data, Hash
  
  def self.admin
    setting = Setting.find_by_setting_type(:admin)
    setting = Setting.create(:setting_type => :admin, :data => $default_admin_settings) if setting.nil?
    setting
  end
end