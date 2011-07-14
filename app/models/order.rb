class Order < ActiveRecord::Base
  validates_presence_of :price, :amount
  validates_numericality_of :price, :amount, :greater_than => 0.0
  
  module  Status
    ACTIVE = :active
    EXPIRED = :expired
    COMPLETE = :complete
  end


  def currency
    read_attribute(:currency) || "USD"
  end

  def currency=(cur)
    write_attribute(cur || "USD")
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