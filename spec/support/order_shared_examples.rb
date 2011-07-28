shared_examples_for "an order" do
  let(:order_class) {described_class}
  
  before(:each) do
    @user = Factory(:user)
    @user.funds.each{|f| f.update_attributes(:amount => 1000, :available => 1000) }
  end

  describe "value is stored as " do
    before(:each) do
      AppConfig.set 'SKIP_TRADE_CREATION', true
    end

    it "as an integer" do
      order = order_class.create(:status => Order::Status::ACTIVE, :amount => 100, :price => 10.0001, :user_id => @user.id)
      order.read_attribute(:price).should == 10.0001
      order.price.should == 10.0001
    end

    it "as an integer" do
      order = order_class.create(:status => Order::Status::ACTIVE, :amount => 100, :price =>100.8700001, :user_id => @user.id)
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
      Factory(order_class.to_s.underscore, :status => Order::Status::ACTIVE, :user_id => @user.id)
      Factory(order_class.to_s.underscore, :status => Order::Status::ACTIVE, :user_id => @user.id)
      order_class.active.size.should == 2
    end

    it "shows active orders" do
      Factory(order_class.to_s.underscore, :status => Order::Status::ACTIVE, :user_id => @user.id)
      Factory(order_class.to_s.underscore, :status => Order::Status::EXPIRED, :user_id => @user.id)
      order_class.active.size.should == 1
    end
  end

  describe "oldest" do
    before(:each) do
      order_class.all.each {|o| o.destroy}
    end

    it "shows ordered by time orders" do
      Factory(order_class.to_s.underscore, :updated_at => DateTime.new(2011, 1,10), :status => Order::Status::ACTIVE, :user_id => @user.id)
      Factory(order_class.to_s.underscore, :updated_at => DateTime.new(2011, 1,13), :status => Order::Status::EXPIRED, :user_id => @user.id)
      order_class.oldest.first.status.should eql(Order::Status::ACTIVE.to_s)
    end
  end
end