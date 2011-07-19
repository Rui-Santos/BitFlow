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

  scope :lowest, order('price ASC')
  scope :highest, order('price DESC')
  
  # the return values would in the form of a hash - no object conversion
  def self.historic(user, row_limit = 5)
    historic_data_query = <<-HISTORIC_DATA_QUERY
      SELECT type, id, amount, price, status, trade_id, updated_at FROM (
        SELECT 'Ask' as type, id, amount, price, status, trade_id, updated_at FROM asks WHERE user_id = #{user.id}
        UNION
        SELECT 'Bid' as type, id, amount, price, status, trade_id, updated_at FROM bids WHERE user_id = #{user.id}
      ) orders
      ORDER BY updated_at DESC limit #{row_limit}
    HISTORIC_DATA_QUERY

    ActiveRecord::Base.connection.select_all(historic_data_query)
  end

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