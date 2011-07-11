class Order < ActiveRecord::Base

  module  Status
    ACTIVE = :active
    EXPIRED = :expired
  end

  PRECISION = 1000000000.0

  def price
    (read_attribute(:price).to_f / PRECISION).to_f
  end

  def price=(val)
    write_attribute(:price, (val * PRECISION).to_f) 
  end
  
  def match!
    nil
  end
end