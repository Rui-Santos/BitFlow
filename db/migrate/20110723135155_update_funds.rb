class UpdateFunds < ActiveRecord::Migration
  def self.up
    change_table :funds do |t|
      t.change :amount, :decimal, :precision => 15, :scale => 10, :default => 0
      t.change :available, :decimal, :precision => 15, :scale => 10, :default => 0
      t.change :reserved, :decimal, :precision => 15, :scale => 10, :default => 0
    end
    
    Fund.all.each do |fund|
      fund.amount = 0 unless fund.amount
      fund.available = 0 unless fund.available
      fund.reserved = 0 unless fund.reserved
      fund.save
    end
    
  end

  def self.down
  end
end
