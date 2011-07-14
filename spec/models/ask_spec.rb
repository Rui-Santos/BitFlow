require 'spec_helper'

describe Ask do
  it_behaves_like "an order"
  describe "greater than" do
    it "find higher priced asks" do
      Factory(:ask, :price => 10.01, :amount => 10)
      Ask.greater_price(10.00).first.amount.should == 10
    end
    it "not find lower prices" do
      Factory(:ask, :price => 10.01, :amount => 10.0)
      Ask.greater_price(11.00).should be_empty
    end

    it "find lesser priced asks" do
      Factory(:ask, :price => 10.01, :amount => 11.0)
      Factory(:ask, :price => 1.01, :amount => 11.0)
      Factory(:ask, :price => 9.01, :amount => 11.0)
      Ask.greater_price(10.01).first.amount == 11.0
    end
    
    it "find lesser priced bids in order" do
      ask_9 = Factory(:ask, :price => 9.01, :amount => 11.0)

      ask_10_01  = Factory(:ask, :price => 10.01, :amount => 11.0)
      ask_10_00 = Factory(:ask, :price => 10.00, :amount => 11.0)
      Ask.greater_price(10.00).should == [ask_10_01, ask_10_00]
    end
    
    
  end
end
