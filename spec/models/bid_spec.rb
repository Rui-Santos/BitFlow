require 'spec_helper'

describe Bid do
  it_behaves_like "an order"    
  describe "match bids" do
    before(:each) do
      AppConfig.set 'SKIP_TRADE_CREATION', true
      Ask.all.each(&:destroy)
      Bid.all.each(&:destroy)
    end
    
    describe "greater than" do
      it "find higher priced Bids" do
        Factory(:bid, :price => 10.01, :amount => 10)
        Bid.greater_price_than(10.00).first.amount.should == 10
      end
      it "not find lower prices" do
        Factory(:bid, :price => 10.01, :amount => 10.0)
        Bid.greater_price_than(11.00).should be_empty
      end

      it "find lesser priced bids" do
        Factory(:bid, :price => 10.01, :amount => 11.0)
        Factory(:bid, :price => 1.01, :amount => 11.0)
        Factory(:bid, :price => 9.01, :amount => 11.0)
        Bid.greater_price_than(10.01).first.amount == 11.0
      end

      it "find lesser priced bids in order" do
        bid_9 = Factory(:bid, :price => 9.01, :amount => 11.0)
        bid_10_01  = Factory(:bid, :price => 10.01, :amount => 11.0)
        bid_10_00 = Factory(:bid, :price => 10.00, :amount => 11.0)
        Bid.greater_price_than(10.00).should == [bid_10_01, bid_10_00]
      end
    end
 
    it "should not match ask when ask price is higher" do
      ask = Factory(:ask, :price => 10.00)
      bid = Factory(:bid, :price => 11.00)
      bid.match!.should_not be_empty
    end
    
    it "should match bid" do
      ask = Factory(:ask, :price => 20.00)
      bid = Factory(:bid, :price => 11.00)
      bid.match!.should be_empty
    end

    it "should match bid when equal" do
      ask = Factory(:ask, :price => 20.01)
      bid = Factory(:bid, :price => 20.01)
      bid.match!.should_not be_nil
    end

    it "should match lowest ask" do
      ask = Factory(:ask, :amount => 3, :price => 20.01)
      ask = Factory(:ask, :amount => 5, :price => 20.00 )
      bid = Factory(:bid, :price => 20.01)
      matches = bid.match!
      matches.size.should == 2
      matches.first.amount.round(2).should == 5.00
      matches[1].amount.round(2).should == 3.00
    end
    
    it "should order oldest first" do
      ask = Factory(:ask, :amount => 3, :price => 20.01, :updated_at => 5.hours.ago)
      ask = Factory(:ask, :amount => 5, :price => 20.01, :updated_at => 1.hour.ago)
      bid = Factory(:bid, :price => 20.01)
      matches = bid.match!
      matches.size.should == 2
      matches.first.amount.round(2).should == 3.00
      matches[1].amount.round(2).should == 5.00
    end
  end

  describe "create trade" do
    before(:each) do
      AppConfig.set('SKIP_TRADE_CREATION', true)
      @bid = Factory(:bid, :price => 10.1, :amount => 10)
      @ask = Factory(:ask, :amount => 10, :price => 10.1)
      @ask6 = Factory(:ask, :amount => 6, :price => 10.1)
      @ask4 = Factory(:ask, :amount => 4, :price => 10.1)
      AppConfig.set('SKIP_TRADE_CREATION', false)
    end
    
    it "does not happen when no matches" do
      Ask.expects(:order_queue).returns([])  
      trade = @bid.create_trades
      trade.should be_nil
    end
    it "when bid matches exactly" do
      Ask.stubs(:order_queue).returns([@ask])  
      trade = @bid.create_trades
      trade.asks.size.should == 1
      trade.asks.first.should be_complete
      trade.bids.first.should == @bid
      @bid.should be_complete
    end

    it "when ask multiple bids matches exactly" do
      Ask.stubs(:order_queue).returns([@ask6, @ask4])  
      trade = @bid.create_trades
      trade.asks.size.should == 2
      trade.asks.first.should be_complete
      trade.asks[1].should be_complete
      trade.bids.first.should == @bid
      @bid.should be_complete
    end

    it "skip remaining bids when more matches exist" do
      Ask.stubs(:order_queue).returns([@ask6, @ask4, @ask])  
      trade = @bid.create_trades
      trade.asks.size.should == 2
      trade.asks.first.should be_complete
      trade.asks[1].should be_complete
      @ask.should be_active
      trade.bids.first.should == @bid
      @bid.should be_complete
    end
  end

  
end
