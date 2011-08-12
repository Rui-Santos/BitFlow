class Ask < Order
  set_table_name :asks
  has_many :trades

  def reverse_class; Bid; end

  def self.order_queue(value)
    active.lesser_price_than(value).oldest
  end

  def to_json(*args)
    super(*args).merge(:type => 'ask')
  end
  
  def bid?
    false
  end
end
