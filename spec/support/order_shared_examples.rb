shared_examples_for "an order" do
  let(:order_class) {described_class}

  describe "value is stored as " do
    it "as an integer" do
      order = order_class.create(:status => Order::Status::ACTIVE, :amount => 100, :price => 10.0001)
      order.read_attribute(:price).should == 10.0001
      order.price.should == 10.0001
    end
    it "as an integer" do
      order = order_class.create(:status => Order::Status::ACTIVE, :amount => 100, :price =>100.8700001)
      order.read_attribute(:price).should == 100.8700001
      order.update_attributes(:price => 9.76)
      order.read_attribute(:price).should == 9.76
      order.price.should == 9.76
    end
  end
  
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