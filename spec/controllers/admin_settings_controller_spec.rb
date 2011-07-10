require 'spec_helper'

describe AdminSettingsController do
  describe "getting settings" do
    describe "for regular user" do
      login_user
      it "can't read admin settings" do
        get 'show'
        response.should_not be_success
        response.status.should == 404
        
      end
      it "cant update admin settings " do
        post :update, :daily_withdrawal_limit =>  100
        response.should_not be_success
        response.status.should == 404
        
      end
    
    end
    describe "for admin_user " do
      login_admin
      before(:each) do
        Setting.admin.destroy
        Factory(:admin_setting)
      end
      
      it "should get settings" do
        get 'show'
        settings = assigns[:settings]
        settings.has_key?(:minimum_commission_fee)
        settings.has_key?(:daily_withdrawal_limit)
        settings.has_key?(:circuit_breaker_change_percent)
        settings.has_key?(:circuit_breaker_change_period)
      end

      it "should update settings when only some given" do
        original_settings = Setting.admin.data
        post 'update', :setting => {:circuit_breaker_change_percent => 99}
        new_settings = Setting.admin.reload.data
        new_settings["circuit_breaker_change_percent"].should == 99
        # settings.has_key?(:daily_withdrawal_limit)
        # settings.has_key?(:circuit_breaker_change_percent)
        # settings.has_key?(:circuit_breaker_change_period)
      end
    end
  end
  describe "updating settings" do
  end
end
