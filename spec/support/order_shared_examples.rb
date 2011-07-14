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
  describe "active" do
    before(:each) do
      order_class.all.each {|o| o.destroy}
    end
    it "shows active orders" do
      Factory(order_class.to_s.underscore, :status => Order::Status::ACTIVE)
      Factory(order_class.to_s.underscore, :status => Order::Status::ACTIVE)
      order_class.active.size.should == 2
    end

    it "shows active orders" do
      Factory(order_class.to_s.underscore, :status => Order::Status::ACTIVE)
      Factory(order_class.to_s.underscore, :status => Order::Status::EXPIRED)
      order_class.active.size.should == 1
    end
  end

  describe "recent" do
    before(:each) do
      order_class.all.each {|o| o.destroy}
    end
    
    it "shows ordered by time orders" do
      Factory(order_class.to_s.underscore, :updated_at => DateTime.new(2011, 1,10), :status => Order::Status::ACTIVE)
      Factory(order_class.to_s.underscore, :updated_at => DateTime.new(2011, 1,13), :status => Order::Status::EXPIRED)
      order_class.recent.first.status.should eql(Order::Status::EXPIRED.to_s)
    end
  end
end