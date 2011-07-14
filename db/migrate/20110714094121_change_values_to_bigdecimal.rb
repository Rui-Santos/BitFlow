class ChangeValuesToBigdecimal < ActiveRecord::Migration
  def self.up
    change_column :asks, :price, :decimal, :precision => 15, :scale => 10
    change_column :asks, :amount, :decimal, :precision => 15, :scale => 10
    change_column :bids, :price, :decimal, :precision => 15, :scale => 10
    change_column :bids, :amount, :decimal, :precision => 15, :scale => 10
  end

  def self.down
  end
end
