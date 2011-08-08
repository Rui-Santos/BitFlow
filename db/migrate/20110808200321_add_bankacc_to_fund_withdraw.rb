class AddBankaccToFundWithdraw < ActiveRecord::Migration
  def self.up
    remove_column :fund_withdraw_requests, :beneficiary_name
    remove_column :fund_withdraw_requests, :beneficiary_address
    change_table :fund_withdraw_requests do |t|
      t.references :bankaccount
    end
  end

  def self.down
    remove_column :fund_withdraw_requests, :bankaccount_id
    add_column :fund_withdraw_requests, :beneficiary_name, :string
    add_column :fund_withdraw_requests, :beneficiary_address, :string    
  end
end
