class AddNetAmountOnFundDeposit < ActiveRecord::Migration
  def self.up
    add_column :fund_deposits, :net_amount, :decimal, :precision => 15, :scale => 10

    FundDeposit.all.each {|fd| fd.update_attribute(:net_amount, fd.amount) unless fd.net_amount}
  end

  def self.down
    remove_column :fund_deposits, :net_amount
  end
end
