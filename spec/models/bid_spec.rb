require 'spec_helper'

describe Bid do
  it_behaves_like "an order"    
  
  describe "match" do
    before(:each) do
      Ask.all.each{|a|a.destroy}
    end
    
    it "should not match" do
      trade = Factory.build(:bid,:amount => 10, :value => 10.2).match!
      trade.should be_nil
    end
  end
end
