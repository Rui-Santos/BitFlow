class CreateFundWithdrawRequests < ActiveRecord::Migration
  def self.up
    create_table :fund_withdraw_requests do |t|
      t.string :currency
      t.decimal :amount, :precision => 15, :scale => 10
      t.references :user
      t.string :message
      t.string :status
      t.string :status_comment
      t.decimal :fee, :precision => 15, :scale => 10
      t.string :beneficiary_name
      t.string :beneficiary_address      
      t.timestamps
    end
    change_table :fund_transaction_details do |t|
      t.references :fund_withdraw_request
    end
  end

  def self.down
    drop_table :fund_withdraw_requests
    remove_column :fund_transaction_details, :fund_withdraw_request_id
  end
end
