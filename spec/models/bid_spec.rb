require 'spec_helper'

describe Bid do
  it_behaves_like "an order"    

  before(:each) do
    AppConfig.set 'SKIP_TRADE_CREATION', true
    Ask.all.each(&:destroy)
    Bid.all.each(&:destroy)
    @user = Factory(:user)
    @admin = Factory(:admin)
    @user.funds.each{|f| f.update_attributes(:amount => 10000, :available => 1000) }
  end

  describe "match bids" do
   
    
    describe "greater than" do
      it "find higher priced Bids" do
        Factory(:bid, :price => 10.01, :amount => 10, :user_id => @user.id)
        Bid.greater_price_than(10.00).first.amount.should == 10
      end

      it "not find lower prices" do
        Factory(:bid, :price => 10.01, :amount => 10.0, :user_id => @user.id)
        Bid.greater_price_than(11.00).should be_empty
      end

      it "find lesser priced bids" do
        Factory(:bid, :price => 10.01, :amount => 11.0, :user_id => @user.id)
        Factory(:bid, :price => 1.01, :amount => 11.0, :user_id => @user.id)
        Factory(:bid, :price => 9.01, :amount => 11.0, :user_id => @user.id)
        Bid.greater_price_than(10.01).first.amount == 11.0
      end

      it "find lesser priced bids in order" do
        bid_9 = Factory(:bid, :price => 9.01, :amount => 11.0, :user_id => @user.id)
        bid_10_01  = Factory(:bid, :price => 10.01, :amount => 11.0, :user_id => @user.id)
        bid_10_00 = Factory(:bid, :price => 10.00, :amount => 11.0, :user_id => @user.id)
        Bid.greater_price_than(10.00).should == [bid_10_01, bid_10_00]
      end
    end
    describe "limit" do
      it "should not match ask when ask price is higher" do
        ask = Factory(:ask, :price => 10.00, :user_id => @user.id)
        bid = Factory(:bid, :price => 11.00, :user_id => @user.id)
        bid.match.should_not be_empty
      end

      it "should match bid" do
        ask = Factory(:ask, :price => 20.00, :user_id => @user.id)
        bid = Factory(:bid, :price => 11.00, :user_id => @user.id)
        bid.match.should be_empty
      end

      it "should match bid when equal" do
        ask = Factory(:ask, :price => 20.01, :user_id => @user.id)
        bid = Factory(:bid, :price => 20.01, :user_id => @user.id)
        bid.match.should_not be_nil
      end

      it "should match lowest ask" do
        ask = Factory(:ask, :amount => 3, :price => 20.01, :user_id => @user.id)
        ask = Factory(:ask, :amount => 5, :price => 20.00, :user_id => @user.id)
        bid = Factory.build(:bid, :price => 20.01)
        matches = bid.match
        matches.size.should == 2
        matches.first.amount.round(2).should == 5.00
        matches[1].amount.round(2).should == 3.00
      end

      it "should order oldest first" do
        ask = Factory(:ask, :amount => 3, :price => 20.01, :updated_at => 5.hours.ago, :user_id => @user.id)
        ask = Factory(:ask, :amount => 5, :price => 20.01, :updated_at => 1.hour.ago, :user_id => @user.id)
        bid = Factory(:bid, :price => 20.01, :user_id => @user.id)
        matches = bid.match
        matches.size.should == 2
        matches.first.amount.round(2).should == 3.00
        matches[1].amount.round(2).should == 5.00
      end
    end
    describe "market" do
      before(:each) do
        @bid = Factory(:market_bid, :user_id => @user.id)
      end
      it "should find multiple items in time order order" do
        @bid.match.should be_empty
      end
      
      it "should find all items" do
        ask = Factory(:ask, :price => 11.00, :user_id => @user.id)
        @bid.match.should == [ask]
      end
      it "should find multiple items in price order" do
        ask = Factory(:ask, :price => 11.00, :user_id => @user.id)
        ask2 = Factory(:ask, :price => 13.00, :user_id => @user.id)
        @bid.match.should == [ ask, ask2]
      end
      
      it "should find multiple items in time order order" do
        ask = Factory(:ask, :price => 11.00, :user_id => @user.id, :updated_at => 1.day.ago)
        ask2 = Factory(:ask, :price => 11.00, :user_id => @user.id)
        ask3 = Factory(:ask, :price => 13.00, :user_id => @user.id)
        @bid.match.should == [ ask, ask2, ask3]
      end
    end

  end
  describe "validation" do
    describe "limit" do
      it "should fail when balance does not exist" do
        user =Factory(:user, )
        Factory.build(:bid, :amount => 20000, :price => 100, :user_id => user.id).should_not be_valid
      end

      it "pass if commissions and bitcoins match" do
        Factory.build(:ask, :amount => 200, :price => 1).should_not be_valid
      end
    end
    describe "market" do
      it "is not valid when " do
        @user.usd.update_attributes(:amount => 0.01, :available => 0.01)
        bid = Factory.build(:market_bid, :amount => 2000, :user_id => @user.id)
        bid.should_not be_valid
      end
      it "is not valid when " do
        bid = Factory.build(:market_bid, :amount => 2000, :user_id => @user.id)
        bid.should be_valid
      end
    end
  end

  describe "create trade" do
    describe "limit bids" do
      before(:each) do
        AppConfig.set('SKIP_TRADE_CREATION', true)
        @user = Factory(:user)
        @user.funds.each{|f| f.update_attributes(:amount => 1000, :available => 1000) }
        Trade.all.each(&:destroy)
        @ask = Factory(:ask, :amount => 10, :amount_remaining => 10, :price => 10.1, :user_id => @user.id)
        @ask6 = Factory(:ask, :amount => 6, :amount_remaining => 6, :price => 10.1, :user_id => @user.id)
        @ask4 = Factory(:ask, :amount => 4, :amount_remaining =>  4, :price => 10.1, :user_id => @user.id)

        @bid = Factory.build(:bid, :price => 10.1, :amount => 10, :user_id => @user.id)

        AppConfig.set('SKIP_TRADE_CREATION', false)
      end

      it "does not happen when no matches" do
        Ask.expects(:order_queue).returns([])  
        @bid.save
        Trade.all.should be_empty
      end

      it "when bid matches exactly" do
        Ask.stubs(:order_queue).returns([@ask])  
        @bid.save
        trades = @bid.trades
        trades.size.should == 1
        trades.first.ask.should be_complete
        trades.first.bid.should == @bid
        @bid.should be_complete
      end

      it "when ask multiple bids matches exactly" do
        Ask.stubs(:order_queue).returns([@ask6, @ask4])  
        @bid.save
        trades = @bid.trades
        trades.size.should == 2
        trades[0].ask.should be_complete
        trades[1].ask.should be_complete
        trades[0].bid.should == @bid
        @bid.should be_complete
      end

      it "skip remaining bids when more matches exist" do
        Ask.stubs(:order_queue).returns([@ask6, @ask4, @ask])  
        @bid.save
        trades = @bid.trades
        trades.size.should == 2
        trades[0].ask.should be_complete
        trades[1].ask.should be_complete
        @ask.should be_active
        @bid.should be_complete
      end
      it "is incomplete when ask are not sufficient" do
          Ask.stubs(:order_queue).returns([@ask4])  
          @bid.save
          trades = @bid.trades
          trades.size.should == 1
          trades[0].ask.should be_complete
          @bid.should be_active
          @bid.amount_remaining.should == 6.00
        end
      
    end
    describe "market bids" do
      before(:each) do
        AppConfig.set('SKIP_TRADE_CREATION', true)
        @user = Factory(:user)
        @user.funds.each{|f| f.update_attributes(:amount => 1000, :available => 1000) }
        Trade.all.each(&:destroy)
        @ask = Factory(:ask, :amount => 10, :amount_remaining => 10, :price => 10.1, :user_id => @user.id)
        @ask6 = Factory(:ask, :amount => 6, :amount_remaining => 6, :price => 10.1, :user_id => @user.id)
        @ask4 = Factory(:ask, :amount => 4, :amount_remaining =>  4, :price => 10.1, :user_id => @user.id)

        @bid = Factory.build(:market_bid, :amount => 10, :amount_remaining => 10, :user_id => @user.id)

        AppConfig.set('SKIP_TRADE_CREATION', false)
      end

      it "does not happen when no matches" do
        Ask.expects(:market_order_queue).returns([])  
        begin
          @bid.save
          fail "Excpected Cancelled Exception"
        rescue
          
        end
        Trade.all.should be_empty
      end

      it "when bid matches exactly" do
        Ask.stubs(:market_order_queue).returns([@ask])  
        @bid.save
        trades = @bid.trades
        trades.size.should == 1
        trades.first.ask.should be_complete
        trades.first.bid.should == @bid
        @bid.should be_complete
      end

      it "when ask multiple bids matches exactly" do
        Ask.stubs(:market_order_queue).returns([@ask6, @ask4])  
        @bid.save
        trades = @bid.trades
        trades.size.should == 2
        trades[0].ask.should be_complete
        trades[1].ask.should be_complete
        trades[0].bid.should == @bid
        @bid.should be_complete
      end

      it "skip remaining bids when more matches exist" do
        Ask.stubs(:market_order_queue).returns([@ask6, @ask4, @ask])  
        @bid.save
        trades = @bid.trades
        trades.size.should == 2
        trades[0].ask.should be_complete
        trades[1].ask.should be_complete
        @ask.should be_active
        @bid.should be_complete
      end

      it "is cancelled when ask are not sufficient and all rolled back" do
        Ask.stubs(:market_order_queue).returns([@ask4])  
        begin
          @bid.save
          fail "Expected cancelled Exception"
        rescue
        end

      end
    end
  end

  describe "updating remaining amount" do
    before(:each) do
      @bid = Factory(:bid, :price => 11.00, :user_id => @user.id)
    end
    it "should keep the same status" do
      @bid.update_attribute(:amount_remaining, 2.01)
      @bid.amount_remaining.should == 2.01
      @bid.should be_active
    end

    it "should set bid to complete if 0 remaining" do
      @bid.update_attribute(:amount_remaining, 0)
      @bid.amount_remaining.should == 0
      @bid.should_not be_active
    end
    it "should set bid to cancelled if market and amount is remaining" do
      @bid.order_type = Order::Type::MARKET
      @bid.update_attribute(:amount_remaining, 100)
      @bid.amount_remaining.should == 100
      @bid.reload.should be_cancelled
    end
  end
end
