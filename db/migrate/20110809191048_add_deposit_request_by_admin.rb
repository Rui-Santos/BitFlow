class AddDepositRequestByAdmin < ActiveRecord::Migration
  def self.up
    add_column :fund_deposit_requests, :created_by_admin, :boolean, :default => false
  end

  def self.down
    remove_column :fund_deposit_requests, :created_by_admin
  end
end
