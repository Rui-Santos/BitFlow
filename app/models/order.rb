class Order < ActiveRecord::Base
  
  module  Status
    ACTIVE = :active
    EXPIRED = :expired
    COMPLETE = :complete
  end

  PRECISION = 1000000000.0

  def price
    (read_attribute(:price).to_f / PRECISION).to_f
  end

  def price=(val)
    write_attribute(:price, (val * PRECISION).to_f) 
  end
    
  def match!(order)
    unless order.nil?
      if(order.price == price && order.amount == amount)
         order.update_attributes(:status => Order::Status::COMPLETE)
         self.update_attributes(:status => Order::Status::COMPLETE)
      end
    end
  end
end