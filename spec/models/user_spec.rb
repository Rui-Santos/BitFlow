require 'spec_helper'

describe User do
  describe "fund" do
    it "has reserved and available usd" do
      user = Factory(:user)
      fund = user.funds.detect{|f| f.fund_type == Fund::Type::USD}
      fund.update_attributes(:reserved => 10.01, :available => 9.81)
      puts user.funds.inspect
      user.usd["reserved"].should == 10.01
      user.usd["available"].should == 9.81
    end

    it "has reserved and available btc" do
      user =Factory(:user)
      fund = user.funds.detect{|f| f.fund_type == Fund::Type::BTC}
      fund.update_attributes(:reserved => 87.19, :available => 3.12)
      puts user.btc["reserved"].to_f
      user.btc["reserved"].should == 87.19
      user.btc["available"].should == 3.12
    end
  end
  describe "buy_btc" do
    it "should" do
      
    end
  end
end
