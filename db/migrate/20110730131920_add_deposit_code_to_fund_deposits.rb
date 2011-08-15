class AddDepositCodeToFundDeposits < ActiveRecord::Migration
  def self.up
    add_column :fund_deposits, :deposit_code, :string

    FundDeposit.all.each {|fd| fd.update_attribute(:deposit_code, User.find(fd.user_id).email.downcase) unless fd.deposit_code} rescue nil
  end

  def self.down
    remove_column :fund_deposits, :deposit_code
  end
end
