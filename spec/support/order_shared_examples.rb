shared_examples_for "an order" do
  describe "value is stored as " do
    let(:order) {described_class}
    it "as an integer" do
      order = order.create(:status => Order::Status::ACTIVE, :amount => 100, :price => 10.0001)
      order.read_attribute(:price).should == 10.0001 * Order::PRECISION
      order.price.should == 10.0001
    end
    it "as an integer" do
      order = order.create(:status => Order::Status::ACTIVE, :amount => 100, :price =>100.8700001)
      order.read_attribute(:price).should == 100.8700001 * Order::PRECISION
      order.update_attributes(:price => 9.76)
      order.read_attribute(:price).should == 9.76 * Order::PRECISION
      order.price.should == 9.76
    end
  end
end