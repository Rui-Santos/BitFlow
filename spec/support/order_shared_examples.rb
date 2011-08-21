shared_examples_for "an order" do
  let(:order_class) {described_class}
  
  before(:each) do
    @user = Factory(:user)
    @admin = Factory(:admin)
    @user.funds.each{|f| f.update_attributes(:amount => 5000, :available => 15000) }
  end

  describe "value is stored as " do
    before(:each) do
      AppConfig.set 'SKIP_TRADE_CREATION', true
    end

    it "as an integer" do
      order = order_class.create(:status => Order::Status::ACTIVE, :amount => 100, :price => 10.0001, :user_id => @user.id, :order_type => Order::Type::LIMIT)
      order.read_attribute(:price).should == 10.0001
      order.price.should == 10.0001
    end

    it "as an integer" do
      order = order_class.create(:status => Order::Status::ACTIVE, :amount => 100, :price =>100.8700001, :user_id => @user.id, :order_type => Order::Type::LIMIT)
      order.read_attribute(:price).should == 100.8700001
      order.update_attributes(:price => 9.76)
      order.read_attribute(:price).should == 9.76
      order.price.should == 9.76
    end
  end

  describe "active" do
    before(:each) do
      order_class.all.each(&:destroy)
      @user.funds.each{|f| f.update_attributes(:amount => 5000, :available => 2000) }
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
      order_class.all.each{|x| x.destroy}
    end

    it "shows ordered by time orders" do
      Factory(order_class.to_s.underscore, :updated_at => DateTime.new(2011, 1,10), :status => Order::Status::ACTIVE, :user_id => @user.id)
      Factory(order_class.to_s.underscore, :updated_at => DateTime.new(2011, 1,13), :status => Order::Status::EXPIRED, :user_id => @user.id)
      order_class.oldest.first.status.should eql(Order::Status::ACTIVE.to_s)
    end
  end
  describe "validations" do
    describe "for limit order" do
      it "fails when price does not exist" do
        Factory.build(order_class.to_s.underscore, :price => nil).should_not be_valid
      end
      it "fails when price does not exist" do
        Factory.build(order_class.to_s.underscore, :price => -1.21).should_not be_valid
      end

      it "fails when price does not exist" do
        Factory.build(order_class.to_s.underscore, :price => "avc").should_not be_valid
      end

      it "fails when amount does not exist" do
        Factory.build(order_class.to_s.underscore, :amount => nil).should_not be_valid
      end

      it "fails when amount is negative" do
        Factory.build(order_class.to_s.underscore, :amount => -1.22).should_not be_valid
      end

      it "fails when amount is not number" do
        Factory.build(order_class.to_s.underscore, :amount => "-1.22").should_not be_valid
      end
      
    end
  end
  
end