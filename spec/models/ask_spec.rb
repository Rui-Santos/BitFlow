require 'spec_helper'

describe Ask do
  it_behaves_like "an order"

  before(:each) do
    AppConfig.set 'SKIP_TRADE_CREATION', true
    Ask.all.each(&:destroy)
    Bid.all.each(&:destroy)
    @user = Factory(:user)
    @user.funds.each{|f| f.update_attributes(:amount => 1000, :available => 1000) }
  end
  
  describe "scopes" do
    it "find lesser priced asks" do
      Factory(:ask, :price => 10.01, :amount => 10, :user_id => @user.id)
      Ask.lesser_price_than(10.00).should be_empty
    end
    it "find lesser priced asks" do
      Factory(:ask, :price => 10.01, :amount => 10.0, :user_id => @user.id)
      Ask.lesser_price_than(11.00).first.amount == 10.0
    end

    it "find lesser priced asks" do
      Factory(:ask, :price => 10.01, :amount => 11.0, :user_id => @user.id)
      Factory(:ask, :price => 19.01, :amount => 11.0, :user_id => @user.id)
      Factory(:ask, :price => 12.01, :amount => 11.0, :user_id => @user.id)
      Ask.lesser_price_than(10.01).first.amount == 11.0
    end

    it "find lesser priced asks in order" do
      ask_9 = Factory(:ask, :price => 9.01, :amount => 11.0, :user_id => @user.id)
      ask_10_01  = Factory(:ask, :price => 10.01, :amount => 11.0, :user_id => @user.id)
      ask_10_00 = Factory(:ask, :price => 10.00, :amount => 11.0, :user_id => @user.id)
      Ask.lesser_price_than(10.01).should == [ask_9, ask_10_00, ask_10_01]
    end
  end
  
  
  it "should not match ask when ask price is higher" do
    ask = Factory(:ask, :price => 12.00, :user_id => @user.id)
    bid = Factory(:bid, :price => 11.00, :user_id => @user.id)
    ask.match!.should be_empty
  end
  
  it "should match bid" do
    ask = Factory(:ask, :price => 20.00, :user_id => @user.id)
    bid = Factory(:bid, :price => 21.00, :user_id => @user.id)
    ask.match!.should_not be_empty
  end

  it "should match bid when equal" do
    ask = Factory(:ask, :price => 20.01, :user_id => @user.id)
    bid = Factory(:bid, :price => 20.01, :user_id => @user.id)
    ask.match!.should_not be_empty
  end
  
  it "should order oldest first" do
    bid = Factory(:bid, :amount => 3, :price => 20.01, :updated_at => 5.hours.ago, :user_id => @user.id)
    bid = Factory(:bid, :amount => 5, :price => 20.01, :updated_at => 1.hour.ago, :user_id => @user.id)
    bid = Factory(:bid, :amount => 50, :price => 19.01, :updated_at => 5.minutes.ago, :user_id => @user.id)
    ask = Factory(:ask, :price => 20.01, :user_id => @user.id)

    matches = ask.match!
    
    matches.size.should == 2
    matches.first.amount.should == 3
    matches[1].amount.should == 5
  end

  describe "create trade" do
    before(:each) do
      @ask = Factory(:ask, :price => 10.1, :amount => 10, :user_id => @user.id)
      @bid = Factory(:bid, :amount => 10, :price => 10.1, :user_id => @user.id)
      @bid6 = Factory(:bid, :amount => 6, :price => 10.1, :user_id => @user.id)
      @bid4 = Factory(:bid, :amount => 4, :price => 10.1, :user_id => @user.id)
      AppConfig.set('SKIP_TRADE_CREATION', false)
    end

    it "does not happen when no matches" do
      Bid.expects(:order_queue).returns([])  
      @ask.create_trades
      @ask.trades.should be_empty
    end

    it "when bid matches exactly" do
      Bid.stubs(:order_queue).returns([@bid])  
      @ask.create_trades
      trades = @ask.trades
      trades.size.should == 1
      trades[0].bid.should be_complete
      trades[0].ask.should == @ask
      @ask.should be_complete
    end

    it "when bid multiple bids matches exactly" do
      Bid.stubs(:order_queue).returns([@bid6, @bid4])  
      @ask.create_trades
      trades = @ask.trades
      trades.size.should == 2
      trades[0].bid.should be_complete
      trades[1].bid.should be_complete
      trades[0].ask.should == @ask
      @ask.should be_complete
    end

    it "skip remaining bids when more matches exist" do
      Bid.stubs(:order_queue).returns([@bid6, @bid4, @bid])  
      @ask.create_trades
      trades = @ask.trades
      trades.size.should == 2
      trades[0].bid.should be_complete
      trades[1].bid.should be_complete
      @bid.should be_active
      trades[0].ask.should == @ask
      @ask.should be_complete
    end
  end
end
