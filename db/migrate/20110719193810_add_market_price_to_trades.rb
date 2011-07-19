class AddMarketPriceToTrades < ActiveRecord::Migration
  def self.up
    add_column :trades, :market_price, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :trades, :market_price
  end
end
