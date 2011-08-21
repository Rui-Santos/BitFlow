class Order < ActiveRecord::Base

  validates_numericality_of :price, :greater_than => 0.0, :if => proc { |bid| bid.limit? }
  validates_numericality_of :amount, :greater_than => 0.0
  validates_presence_of :price, :if => proc { |bid| bid.limit? }
  validates_presence_of :amount

  belongs_to :user
  after_initialize :default_order_type!

  module  Status
    ACTIVE = :active
    COMPLETE = :complete
    EXPIRED = :expired
    CANCELLED = :cancelled
  end

  module Type
    MARKET = :market
    LIMIT  = :limit
  end

  
  scope :active, lambda {
    where("status = '#{Order::Status::ACTIVE}'")
  }

  scope :oldest, order("updated_at ASC")  

  scope :lowest, order('price ASC')
  
  scope :highest, order('price DESC')

  scope :user_transactions, lambda { |user|
    where("user_id = ?", user.id).order(:updated_at).reverse_order
  }

  def default_order_type!
    order_type = Order::Type::LIMIT
  end
  
  def amount_remaining=(val)
    write_attribute(:amount_remaining, val)
    write_attribute(:status, Order::Status::COMPLETE) if val == 0
  end
  
  # the return values would in the form of a hash - no object conversion
  def self.non_executed(user, row_limit = 5)
    historic_data_query = <<-HISTORIC_DATA_QUERY
      SELECT type, id, amount_remaining, price, status, updated_at, total_price FROM (
        SELECT 'Ask' as type, id, amount_remaining, price, status, updated_at, (amount_remaining * price) as total_price FROM asks WHERE user_id = #{user.id} and status = '#{Status::ACTIVE}'
        UNION
        SELECT 'Bid' as type, id, amount_remaining, price, status, updated_at, (amount_remaining * price) as total_price FROM bids WHERE user_id = #{user.id} and status = '#{Status::ACTIVE}'
      ) orders
      ORDER BY updated_at DESC limit #{row_limit}
    HISTORIC_DATA_QUERY

    ActiveRecord::Base.connection.select_all(historic_data_query)
  end

  # the return values would in the form of a hash - no object conversion
  def self.executed(user, row_limit = 5)
    historic_data_query = <<-HISTORIC_DATA_QUERY
      SELECT id, sold, bought, price, execution_price, executed_at, type FROM (
        SELECT asks.id, trades.amount as sold, (trades.amount * trades.market_price) as bought, price, trades.market_price as execution_price, trades.updated_at as executed_at, 'Ask' as type
        FROM asks INNER JOIN trades ON asks.id = trades.ask_id
        WHERE user_id = #{user.id}
        UNION
        SELECT bids.id, (trades.amount * trades.market_price) as sold, trades.amount as bought, price, trades.market_price as execution_price, trades.updated_at as executed_at, 'Bid' as type
        FROM bids INNER JOIN trades ON bids.id = trades.bid_id
        WHERE user_id = #{user.id}
      ) orders
      ORDER BY executed_at DESC limit #{row_limit}
    HISTORIC_DATA_QUERY

    ActiveRecord::Base.connection.select_all(historic_data_query)
  end

  def self.lesser_price_than(price)
    where("price <= ?", price).order("price ASC")
  end

  def self.greater_price_than(price)
    where("price >= ?", price).order("price DESC")
  end

  def active?
    status == Status::ACTIVE || status.to_sym == Status::ACTIVE
  end
  
  def market?
    order_type == Type::MARKET || order_type.to_sym == Type::MARKET
  end

  def limit?
    order_type == Type::LIMIT || order_type.to_sym == Type::LIMIT
  end

  def complete?
    status == Status::COMPLETE || status.to_sym == Status::COMPLETE
  end

  def currency
    read_attribute(:currency) || "USD"
  end

  def currency=(cur)
    write_attribute(:currency, (cur || "USD"))
  end
  
  def to_json(*args)
    {:price => price, :amount => amount, :currency => currency, :status => status}
  end
end