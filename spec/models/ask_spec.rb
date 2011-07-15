require 'spec_helper'

describe Ask do
  it_behaves_like "an order"

  before(:each) do
    AppConfig.set 'SKIP_TRADE_CREATION', true
    Ask.all.each(&:destroy)
    Bid.all.each(&:destroy)
  end
  
  describe "scopes" do
    it "find lesser priced asks" do
      Factory(:ask, :price => 10.01, :amount => 10)
      Ask.lesser_price_than(10.00).should be_empty
    end
    it "find lesser priced asks" do
      Factory(:ask, :price => 10.01, :amount => 10.0)
      Ask.lesser_price_than(11.00).first.amount == 10.0
    end

    it "find lesser priced asks" do
      Factory(:ask, :price => 10.01, :amount => 11.0)
      Factory(:ask, :price => 19.01, :amount => 11.0)
      Factory(:ask, :price => 12.01, :amount => 11.0)
      Ask.lesser_price_than(10.01).first.amount == 11.0
    end

    it "find lesser priced asks in order" do
      ask_9 = Factory(:ask, :price => 9.01, :amount => 11.0)
      ask_10_01  = Factory(:ask, :price => 10.01, :amount => 11.0)
      ask_10_00 = Factory(:ask, :price => 10.00, :amount => 11.0)
      Ask.lesser_price_than(10.01).should == [ask_9, ask_10_00, ask_10_01]
    end
  end
  
  
  it "should not match ask when ask price is higher" do
    ask = Factory(:ask, :price => 12.00)
    bid = Factory(:bid, :price => 11.00)
    ask.match!.should be_empty
  end
  
  it "should match bid" do
    ask = Factory(:ask, :price => 20.00)
    bid = Factory(:bid, :price => 21.00)
    ask.match!.should_not be_empty
  end

  it "should match bid when equal" do
    ask = Factory(:ask, :price => 20.01)
    bid = Factory(:bid, :price => 20.01)
    ask.match!.should_not be_empty
  end
  
  it "should order oldest first" do
    bid = Factory(:bid, :amount => 3, :price => 20.01, :updated_at => 5.hours.ago)
    bid = Factory(:bid, :amount => 5, :price => 20.01, :updated_at => 1.hour.ago)
    bid = Factory(:bid, :amount => 50, :price => 19.01, :updated_at => 5.minutes.ago)
    ask = Factory(:ask, :price => 20.01)

    matches = ask.match!
    
    matches.size.should == 2
    matches.first.amount.should == 3
    matches[1].amount.should == 5
  end

  describe "create trade" do
    before(:each) do
      @ask = Factory(:ask, :price => 10.1, :amount => 10)
      @bid = Factory(:bid, :amount => 10, :price => 10.1)
      @bid6 = Factory(:bid, :amount => 6, :price => 10.1)
      @bid4 = Factory(:bid, :amount => 4, :price => 10.1)
      AppConfig.set('SKIP_TRADE_CREATION', false)
    end
    it "does not happen when no matches" do
      Bid.expects(:order_queue).returns([])  
      trade = @ask.create_trades
      trade.should be_nil
    end
    it "when bid matches exactly" do
      Bid.stubs(:order_queue).returns([@bid])  
      trade = @ask.create_trades
      trade.bids.size.should == 1
      trade.bids.first.should be_complete
      trade.asks.first.should == @ask
      @ask.should be_complete
    end

    it "when bid multiple bids matches exactly" do
      Bid.stubs(:order_queue).returns([@bid6, @bid4])  
      trade = @ask.create_trades
      trade.bids.size.should == 2
      trade.bids.first.should be_complete
      trade.bids[1].should be_complete
      trade.asks.first.should == @ask
      @ask.should be_complete
    end

    it "skip remaining bids when more matches exist" do
      Bid.stubs(:order_queue).returns([@bid6, @bid4, @bid])  
      trade = @ask.create_trades
      trade.bids.size.should == 2
      trade.bids.first.should be_complete
      trade.bids[1].should be_complete
      @bid.should be_active
      trade.asks.first.should == @ask
      @ask.should be_complete
    end
  end
end
