class Order < ActiveRecord::Base
  validates_presence_of :price, :amount
  validates_numericality_of :price, :amount, :greater_than => 0.0
  
  module  Status
    ACTIVE = :active
    EXPIRED = :expired
    COMPLETE = :complete
  end

  scope :active, lambda {
    where("status = '#{Order::Status::ACTIVE}'")
  }
  scope :recent, order("updated_at DESC")  

  def currency
    read_attribute(:currency) || "USD"
  end


  def currency=(cur)
    write_attribute(cur || "USD")
  end
  

  def match!
  end
end