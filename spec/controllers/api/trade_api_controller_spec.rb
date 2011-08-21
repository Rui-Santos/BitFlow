require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')
module Api
  describe TradeApiController do
    describe "balance" do
      describe "authorization" do
        it "redirect if token and secret is not provided" do
          get :balance
          response.status.should == 302
        end

        it "unauthorized if token and secret is invalid" do
          user = Factory.create(:user, :token => 10, :secret => 100)
          user.reload
          get :balance, :token => user.token, :secret => 'xxx'
          response.status.should == 401
        end
      end
      describe "balance values" do
        before(:each) do
          @user = Factory.create(:user, :token => 10, :secret => 100)
          @user.reload
        end
        it "authorized if token and secret are provided for a new user" do
          get :balance, :token => @user.token, :secret => @user.secret, :format => :json
          response.should be_success
          balances = JSON.parse(response.body)
          balances["btc"]["amount"].should == 0.0
          balances["btc"]["reserved"].should == 0.0
          balances["btc"]["available"].should == 0.0

          balances["usd"]["amount"].should == 0.0
          balances["usd"]["reserved"].should == 0.0
          balances["usd"]["available"].should == 0.0
        end

        it "authorized if token and secret are provided for an existing user" do
          btc_fund = @user.funds.detect{|f| f.fund_type == Fund::Type::BTC}
          btc_fund.update_attributes(:amount => 98.11, :reserved => 78.02, :available => 20.09)

          usd_fund = @user.funds.detect{|f| f.fund_type == Fund::Type::USD}
          usd_fund.update_attributes(:amount => 10.87, :reserved => 3.12, :available => 7.75)

          get :balance, :token => @user.token, :secret => @user.secret, :format => :json
          response.should be_success
          balances = JSON.parse(response.body)
          balances["btc"]["amount"].should == 98.11
          balances["btc"]["reserved"].should == 78.02
          balances["btc"]["available"].should == 20.09

          balances["usd"]["amount"].should == 10.87
          balances["usd"]["reserved"].should == 3.12
          balances["usd"]["available"].should == 7.75
        end
      end

    end
    describe "orders" do
      describe "authorization" do
        it "redirect if token and secret is not provided" do
          get :orders
          response.status.should == 302
        end

        it "unauthorized if token and secret is invalid" do
          user = Factory.create(:user, :token => 10, :secret => 100)
          user.reload
          get :orders, :token => user.token, :secret => 'xxx'
          response.status.should == 401
        end
      end
      describe "order values" do
        before(:each) do
          @user = Factory.create(:user, :token => 10, :secret => 100)
          @user.reload
        end
      
        it "authorized if token and secret are provided for a new user" do
          get :orders, :token => @user.token, :secret => @user.secret, :format => :json
          response.should be_success
          orders = JSON.parse(response.body)
          orders.should be_empty
        end

        it "should show previous orders" do
          get :orders, :token => @user.token, :secret => @user.secret, :format => :json
          response.should be_success
        end
      end
    end
  end
end