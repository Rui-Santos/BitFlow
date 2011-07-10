require 'spec_helper'

describe AdminSettingController do
  describe "getting settings" do
    describe "for regular user" do
      login_user
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
      it "should update settings when only some given" do
        original_settings = Setting.admin.data
        post 'update', :setting => {:circuit_breaker_change_percent => 99}
        new_settings = Setting.admin.reload.data
        new_settings["circuit_breaker_change_percent"].should == 99
        new_settings["daily_withdrawal_limit"].should == original_settings["daily_withdrawal_limit"]
      end
    end
  end
end
