require 'spec_helper'

describe Ask do
  it_behaves_like "an order"
  before(:each) do
    AppConfig.set 'SKIP_TRADE_CREATION', true
    Ask.all.each(&:destroy)
    Bid.all.each(&:destroy)
    @user = Factory(:user)
    Factory(:admin)
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
  
  describe "validation" do
    describe "limit order" do
      it "should fail when no bitcoin balance" do
        Factory.build(:ask, :amount => 2000, :price => 0.1).should_not be_valid
      end

      it "should fail when no money to pay commissions" do
        @user.usd.update_attribute :available, 0.50
        Setting.admin.data[:commission_fee] = 1.0
        Factory.build(:ask, :amount => 200, :price => 0.1).should_not be_valid
      end

      it "pass if commissions and bitcoins match" do
        Setting.admin.data[:commission_fee] = 1.0
        Factory.build(:ask, :amount => 200, :price => 0.1).should_not be_valid
      end
      
    end
    describe "market order" do
      it "fails if not enough btc" do
        ask = Factory.build(:market_ask, :amount => 2000, :user_id => @user.id)
        ask.should_not be_valid
      end

      it "fails if not enough usd for comissions" do
        @user.usd.update_attributes(:amount => 0.01, :available => 0.01)
        ask = Factory.build(:market_ask, :amount => 100, :user_id => @user.id)
        ask.should_not be_valid
      end
      
      it "passes if not enough btc" do
        ask = Factory.build(:market_ask, :amount => 500, :user_id => @user.id)
        ask.should be_valid
      end
    end
  end
  describe "matches" do
    describe "limit order" do
      it "should not match ask when ask price is higher" do
        ask = Factory(:ask, :price => 12.00, :user_id => @user.id)
        bid = Factory(:bid, :price => 11.00, :user_id => @user.id)
        ask.match.should be_empty
      end

      it "should match bid" do
        ask = Factory(:ask, :price => 20.00, :user_id => @user.id)
        bid = Factory(:bid, :price => 21.00, :user_id => @user.id)
        ask.match.should_not be_empty
      end

      it "should match bid when equal" do
        ask = Factory(:ask, :price => 20.01, :user_id => @user.id)
        bid = Factory(:bid, :price => 20.01, :user_id => @user.id)
        ask.match.should_not be_empty
      end

      it "should order oldest first" do
        bid = Factory(:bid, :amount => 3, :price => 20.01, :updated_at => 5.hours.ago, :user_id => @user.id)
        bid = Factory(:bid, :amount => 5, :price => 20.01, :updated_at => 1.hour.ago, :user_id => @user.id)
        bid = Factory(:bid, :amount => 1, :price => 19.01, :updated_at => 5.minutes.ago, :user_id => @user.id)
        ask = Factory(:ask, :price => 20.01, :user_id => @user.id)

        matches = ask.match

        matches.size.should == 2
        matches.first.amount.should == 3
        matches[1].amount.should == 5
      end
      
    end
    describe "market" do
      before(:each) do
        @ask = Factory(:market_ask, :user_id => @user.id)
      end
      it "should find multiple items in time order order" do
        @ask.match.should be_empty
      end
      
      it "should find all items" do
        bid = Factory(:bid, :price => 11.00, :user_id => @user.id)
        @ask.match.should == [bid]
      end
      it "should find multiple items in price order" do
        bid = Factory(:bid, :price => 11.00, :user_id => @user.id)
        bid2 = Factory(:bid, :price => 13.00, :user_id => @user.id)
        @ask.match.should == [ bid2, bid]
      end

      it "should find multiple items in time order order" do
        bid = Factory(:bid, :price => 11.00, :user_id => @user.id, :updated_at => 1.day.ago)
        bid2 = Factory(:bid, :price => 11.00, :user_id => @user.id)
        bid3 = Factory(:bid, :price => 13.00, :user_id => @user.id)
        @ask.match.should == [ bid3, bid, bid2]
      end
    end
  end

  describe "create trade" do
    describe "limit order" do
      before(:each) do
        @bid = Factory(:bid, :amount => 10,  :amount_remaining => 10, :price => 10.1, :user_id => @user.id)
        @bid6 = Factory(:bid, :amount => 6, :amount_remaining => 6, :price => 10.1, :user_id => @user.id)
        @bid4 = Factory(:bid, :amount => 4,  :amount_remaining => 4,:price => 10.1, :user_id => @user.id)
        AppConfig.set('SKIP_TRADE_CREATION', false)
        @ask = Factory.build(:ask, :price => 10.1, :amount => 10, :amount_remaining => 10, :user_id => @user.id)

      end

      it "does not happen when no matches" do
        Bid.expects(:order_queue).returns([])  
        @ask.save
        @ask.trades.should be_empty
      end

      it "when bid matches exactly" do
        Bid.stubs(:order_queue).returns([@bid])  
        @ask.save
        trades = @ask.trades
        trades.size.should == 1
        trades[0].bid.should be_complete
        trades[0].ask.should == @ask
        @ask.should be_complete
      end

      it "when bid multiple bids matches exactly" do
        Bid.stubs(:order_queue).returns([@bid6, @bid4])  
        @ask.save
        trades = @ask.trades
        trades.size.should == 2
        trades[0].bid.should be_complete
        trades[1].bid.should be_complete
        trades[0].ask.should == @ask
        @ask.should be_complete
      end

      it "skip remaining bids when more matches exist" do
        Bid.stubs(:order_queue).returns([@bid6, @bid4, @bid])  
        @ask.save
        trades = @ask.trades
        trades.size.should == 2
        trades[0].bid.should be_complete
        trades[1].bid.should be_complete
        @bid.should be_active
        trades[0].ask.should == @ask
        @ask.should be_complete
      end

      it "is incomplete when bids are not sufficient" do
        Bid.stubs(:order_queue).returns([@bid4])  
        @ask.save
        trades = @ask.trades
        trades.size.should == 1
        trades[0].bid.should be_complete
        @ask.should be_active
        @ask.amount_remaining.should == 6.00
      end
    end
    describe "market order" do
      before(:each) do
        AppConfig.set('SKIP_TRADE_CREATION', true)
        @user = Factory(:user)
        @user2 = Factory(:user)
        @asker = Factory(:user)
        @user.funds.each{|f| f.update_attributes(:amount => 1000, :available => 1000) }
        @user2.funds.each{|f| f.update_attributes(:amount => 1000, :available => 1000) }
        @asker.funds.each{|f| f.update_attributes(:amount => 1000, :available => 1000) }
        Trade.all.each(&:destroy)
        @bid = Factory(:bid, :amount => 10, :amount_remaining => 10, :price => 10.1, :user_id => @user.id)
        @bid6 = Factory(:bid, :amount => 6, :amount_remaining => 6, :price => 10.1, :user_id => @user2.id)
        @bid4 = Factory(:bid, :amount => 4, :amount_remaining =>  4, :price => 10.1, :user_id => @user.id)

        @ask = Factory.build(:market_ask, :amount => 10, :amount_remaining => 10, :user_id => @asker.id)

        AppConfig.set('SKIP_TRADE_CREATION', false)
      end

      it "does not happen when no matches" do
        Bid.expects(:market_order_queue).returns([])  
        @ask.save
        @ask.should be_cancelled
        Trade.all.should be_empty
      end

      it "when bid matches exactly" do
        Bid.stubs(:market_order_queue).returns([@bid])  
        @ask.save
        trades = @ask.trades
        trades.size.should == 1
        trades.first.bid.should be_complete
        trades.first.ask.should == @ask
        @ask.should be_complete
      end

      it "when ask multiple bids matches exactly" do
        Bid.stubs(:market_order_queue).returns([@bid6, @bid4])  
        @ask.save
        trades = @ask.trades
        trades.size.should == 2
        trades[0].bid.should be_complete
        trades[1].bid.should be_complete
        trades[0].ask.should == @ask
        @ask.should be_complete
        
        @bid6.reload.should be_complete
        @bid4.reload.should be_complete

        @asker.reload.usd.amount.should == 1101 - Setting.admin.data[:commission_fee]
        @asker.btc.amount.should == 990
        @user.reload
        @user2.reload
        
        @user.usd.amount.should == 959.6 #
        @user.btc.amount.should == 1004
        @user2.usd.amount.should == 939.4 #
        @user2.btc.amount.should == 1006
      end

      it "skip remaining bids when more matches exist" do
        Bid.stubs(:market_order_queue).returns([@bid6, @bid4, @bid])  
        @ask.save
        trades = @ask.trades
        trades.size.should == 2
        trades[0].bid.should be_complete
        trades[1].bid.should be_complete
        @ask.should be_complete
        @bid.should be_active
      end

      it "is cancelled when asks are not sufficient and all rolled back" do
        Bid.stubs(:market_order_queue).returns([@bid4])  
        @ask.save
        
        @ask.should be_cancelled
        @bid4.reload.should be_active

        @user.reload.usd.amount.should == 1000
        @user.reload.usd.reserved.should == 0
      end
    end
  end

  describe "update amount remaining" do
    before(:each) do
      @ask = Factory(:ask, :price => 11.00, :user_id => @user.id)
    end
    
    it "should not update status when amount remaining is > 0" do
      @ask.amount_remaining = 1.91
      @ask.amount_remaining.should == 1.91
      @ask.should be_active
    end

    it "should not update status when amount remaining is > 0" do
      @ask.amount_remaining = 0
      @ask.amount_remaining.should == 0
      @ask.should_not be_active
    end
  end
end
