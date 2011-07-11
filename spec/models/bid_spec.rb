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
  end
end
