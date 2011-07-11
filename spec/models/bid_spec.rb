require 'spec_helper'

describe Bid do
  it_behaves_like "an order"    
  
  describe "match" do
    before(:each) do
      Ask.all.each{|a|a.destroy}
    end
    
    it "should not match" do
      trade = Factory.build(:bid,:price => 10).match!(Factory.build(:ask,:price=>10.2))
      trade.should be_nil
    end
    
    it "should match equal bid and ask" do
      bid = Factory.build(:bid,:price => 10,:amount=>5)
      ask = (Factory.build(:ask,:price=>10,:amount=>5))
      bid.match!(ask)
      bid.status.should == Order::Status::COMPLETE
      ask.status.should == Order::Status::COMPLETE
    end
    
    it "should match equal ask and bid" do
      bid = Factory.build(:bid,:price => 10,:amount=>5)
      ask = (Factory.build(:ask,:price=>10,:amount=>5))
      ask.match!(bid)
      bid.status.should == Order::Status::COMPLETE
      ask.status.should == Order::Status::COMPLETE
    end
    
  end
end
