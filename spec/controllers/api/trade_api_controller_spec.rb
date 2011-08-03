require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe TradeApiController do
  describe "authorization" do
    it "unauthorized if token and secret is not provided" do
      get :balance
      response.status.should == 401
    end

    it "unauthorized if token and secret is invalid" do
      user = Factory.create(:user, :token => 10, :secret => 100)
      user.reload
      get :balance, :token => user.token, :secret => 'xxx'
      response.status.should == 401
    end

    it "authorized if token and secret are provided" do
      user = Factory.create(:user, :token => 10, :secret => 100)
      user.reload
      get :balance, :token => user.token, :secret => user.secret, :format => :json
      response.should be_success
    end
  end
end