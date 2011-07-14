require 'spec_helper'

describe Bid do
  it_behaves_like "an order"    
  describe "matching asks" do
    it "find lesser priced bids" do
      Factory(:bid, :price => 10.01, :amount => 10)
      Bid.lesser_price(10.00).should be_empty
    end
    it "find lesser priced bids" do
      Factory(:bid, :price => 10.01, :amount => 10.0)
      Bid.lesser_price(11.00).first.amount == 10.0
    end

    it "find lesser priced bids" do
      Factory(:bid, :price => 10.01, :amount => 11.0)
      Factory(:bid, :price => 19.01, :amount => 11.0)
      Factory(:bid, :price => 12.01, :amount => 11.0)
      Bid.lesser_price(10.01).first.amount == 11.0
    end

    it "find lesser priced bids in order" do
      bid_9 = Factory(:bid, :price => 9.01, :amount => 11.0)

      bid_10_01  = Factory(:bid, :price => 10.01, :amount => 11.0)
      bid_10_00 = Factory(:bid, :price => 10.00, :amount => 11.0)
      Bid.lesser_price(10.01).should == [bid_10_01, bid_10_00, bid_9]
    end
  end
end
