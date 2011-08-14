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

    it "should not match ask when ask price is higher" do
      ask = Factory(:ask, :price => 10.00, :user_id => @user.id)
      bid = Factory(:bid, :price => 11.00, :user_id => @user.id)
      bid.match!.should_not be_empty
    end
    
    it "should match bid" do
      ask = Factory(:ask, :price => 20.00, :user_id => @user.id)
      bid = Factory(:bid, :price => 11.00, :user_id => @user.id)
      bid.match!.should be_empty
    end

    it "should match bid when equal" do
      ask = Factory(:ask, :price => 20.01, :user_id => @user.id)
      bid = Factory(:bid, :price => 20.01, :user_id => @user.id)
      bid.match!.should_not be_nil
    end

    it "should match lowest ask" do
      ask = Factory(:ask, :amount => 3, :price => 20.01, :user_id => @user.id)
      ask = Factory(:ask, :amount => 5, :price => 20.00, :user_id => @user.id)
      bid = Factory.build(:bid, :price => 20.01)
      matches = bid.match!
      matches.size.should == 2
      matches.first.amount.round(2).should == 5.00
      matches[1].amount.round(2).should == 3.00
    end
    
    it "should order oldest first" do
      ask = Factory(:ask, :amount => 3, :price => 20.01, :updated_at => 5.hours.ago, :user_id => @user.id)
      ask = Factory(:ask, :amount => 5, :price => 20.01, :updated_at => 1.hour.ago, :user_id => @user.id)
      bid = Factory(:bid, :price => 20.01, :user_id => @user.id)
      matches = bid.match!
      matches.size.should == 2
      matches.first.amount.round(2).should == 3.00
      matches[1].amount.round(2).should == 5.00
    end
  end
  describe "validation" do
    
    it "should fail when balance does not exist" do
      user =Factory(:user, )
      Factory.build(:bid, :amount => 20000, :price => 100, :user_id => user.id).should_not be_valid
    end


    it "pass if commissions and bitcoins match" do
      Factory.build(:ask, :amount => 200, :price => 1).should_not be_valid
    end
  end

  describe "create trade" do
    before(:each) do
      pending
      AppConfig.set('SKIP_TRADE_CREATION', true)
      @user = Factory(:user)
      @user.funds.each{|f| f.update_attributes(:amount => 1000, :available => 1000) }

      @bid = Factory(:bid, :price => 10.1, :amount => 10, :user_id => @user.id)
      @ask = Factory(:ask, :amount => 10, :price => 10.1, :user_id => @user.id)
      @ask6 = Factory(:ask, :amount => 6, :price => 10.1, :user_id => @user.id)
      @ask4 = Factory(:ask, :amount => 4, :price => 10.1, :user_id => @user.id)
      AppConfig.set('SKIP_TRADE_CREATION', false)
    end

    it "does not happen when no matches" do
      Ask.expects(:order_queue).returns([])  
      @bid.create_trades
      @bid.trades.should be_empty
    end

    it "when bid matches exactly" do
      Ask.stubs(:order_queue).returns([@ask])  
      @bid.create_trades
      trades = @bid.trades
      trades.size.should == 1
      trades[0].ask.should be_complete
      trades[0].bid.should == @bid
      @bid.should be_complete
    end

    it "when ask multiple bids matches exactly" do
      Ask.stubs(:order_queue).returns([@ask6, @ask4])  
      @bid.create_trades
      trades = @bid.trades
      trades.size.should == 2
      trades[0].ask.should be_complete
      trades[1].ask.should be_complete
      trades[0].bid.should == @bid
      @bid.should be_complete
    end

    it "skip remaining bids when more matches exist" do
      Ask.stubs(:order_queue).returns([@ask6, @ask4, @ask])  
      @bid.create_trades
      trades = @bid.trades
      trades.size.should == 2
      trades[0].ask.should be_complete
      trades[1].ask.should be_complete
      @ask.should be_active
      @bid.should be_complete
    end
  end
end
