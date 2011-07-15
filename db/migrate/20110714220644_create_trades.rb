class CreateTrades < ActiveRecord::Migration
  def self.up
    create_table :trades do |t|
      t.timestamps
    end
    add_column :bids, :trade_id, :integer
    add_column :asks, :trade_id, :integer
  end

  def self.down
    remove_column :bids, :trade_id
    remove_column :asks, :trade_id
    drop_table :trades
  end
end
