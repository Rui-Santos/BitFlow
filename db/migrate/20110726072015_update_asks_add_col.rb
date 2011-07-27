class UpdateAsksAddCol < ActiveRecord::Migration
  def self.up
    add_column :asks, :amount_remaining, :decimal, :precision => 15, :scale => 10, :default => 0
    add_column :bids, :amount_remaining, :decimal, :precision => 15, :scale => 10, :default => 0
    remove_column :asks, :trade_id
    remove_column :bids, :trade_id
  end

  def self.down
    remove_column :asks, :amount_remaining
    remove_column :bids, :amount_remaining
    change_table :asks do |t|
      t.references :trade
    end
    change_table :bids do |t|
      t.references :trade
    end
  end
end
