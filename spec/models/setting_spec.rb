require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Setting do
  describe "admin" do

    before(:each) do
      Setting.admin.destroy
    end
    
    it "default settings are loaded" do
      settings = Setting.admin.data
      settings[:commission_fee].should == 0.25
      settings[:daily_withdrawal_limit].should == 1000
    end

    it "loads current settings" do
      Factory(:admin_setting)
      settings = Setting.admin.data
      settings[:commission_fee].should == 0.5
      settings[:daily_withdrawal_limit].should == 10000
    end
  end
end