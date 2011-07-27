class UpdateTradesAddColum < ActiveRecord::Migration
  def self.up
    change_table :trades do |t|
      t.decimal :amount, :precision => 15, :scale => 10, :default => 0
      t.references :ask
      t.references :bid
    end
  end

  def self.down
    remove_column :trades, :amount
    remove_column :trades, :ask_id
    remove_column :trades, :bid_id
  end
end
