class Order < ActiveRecord::Base
  validates_presence_of :price, :amount
  validates_numericality_of :price, :amount, :greater_than => 0.0
  
  belongs_to :user
  
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

  scope :user_transactions, lambda { |user|
    where("user_id", user.id).order(:updated_at).reverse_order
  }

  # the return values would in the form of a hash - no object conversion
  def self.non_executed(user, row_limit = 5)
    historic_data_query = <<-HISTORIC_DATA_QUERY
      SELECT type, id, amount, price, status, updated_at FROM (
        SELECT 'Ask' as type, id, amount, price, status, updated_at FROM asks WHERE user_id = #{user.id} and status = '#{Status::ACTIVE}'
        UNION
        SELECT 'Bid' as type, id, amount, price, status, updated_at FROM bids WHERE user_id = #{user.id} and status = '#{Status::ACTIVE}'
      ) orders
      ORDER BY updated_at DESC limit #{row_limit}
    HISTORIC_DATA_QUERY

    ActiveRecord::Base.connection.select_all(historic_data_query)
  end

  # the return values would in the form of a hash - no object conversion
  def self.executed(user, row_limit = 5)
    historic_data_query = <<-HISTORIC_DATA_QUERY
      SELECT id, sold, bought, price, execution_price, executed_at FROM (
        SELECT asks.id, amount as sold, '' as bought, price, trades.market_price as execution_price, trades.updated_at as executed_at
        FROM asks
        LEFT OUTER JOIN trades ON asks.trade_id = trades.id
        WHERE user_id = #{user.id} and status = '#{Status::COMPLETE}'
        UNION
        SELECT bids.id, '' as sold, amount as bought, price, trades.market_price as execution_price, trades.updated_at as executed_at
        FROM bids
        LEFT OUTER JOIN trades ON bids.trade_id = trades.id
        WHERE user_id = #{user.id} and status = '#{Status::COMPLETE}'
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