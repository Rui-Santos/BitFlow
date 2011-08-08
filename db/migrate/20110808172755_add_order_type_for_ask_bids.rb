class AddOrderTypeForAskBids < ActiveRecord::Migration
  def self.up
    add_column :bids, :order_type, :string
    add_column :asks, :order_type, :string
  end

  def self.down
    remove_column :asks, :order_type
    remove_column :bids, :order_type
  end
end
