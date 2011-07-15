class Order < ActiveRecord::Base
  validates_presence_of :price, :amount
  validates_numericality_of :price, :amount, :greater_than => 0.0
  
  after_create :create_trades unless AppConfig.is?('SKIP_TRADE_CREATION', false)
  
  module  Status
    ACTIVE = :active
    EXPIRED = :expired
    COMPLETE = :complete
  end

  scope :active, lambda {
    where("status = '#{Order::Status::ACTIVE}'")
  }
  scope :oldest, order("updated_at ASC")  
  
  def self.lesser_price_than(price)
    where("price <= ?", price).order("price ASC")
  end

  def self.greater_price_than(price)
    where("price >= ?", price).order("price DESC")
  end
  

  def complete?
    status == Status::COMPLETE || status.to_sym == Status::COMPLETE
  end

  def active?
    status == Status::ACTIVE || status.to_sym == Status::ACTIVE
  end

  def currency
    read_attribute(:currency) || "USD"
  end


  def currency=(cur)
    write_attribute(cur || "USD")
  end
  
end