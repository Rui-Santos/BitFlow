class BtcWithdrawRequestCreateTable < ActiveRecord::Migration
  def self.up
    drop_table :btc_fund_transfers
    create_table :btc_withdraw_requests do |t|
      t.string :destination_btc_address
      t.decimal :amount, :precision => 15, :scale => 10
      t.references :user
      t.string :message
      t.string :status
      t.timestamps
    end
    add_column :fund_transaction_details, :status, :string
    remove_column :fund_transaction_details, :notes
    add_column :fund_transaction_details, :message, :string
    change_table :fund_transaction_details do |t|
      t.references :trade
      t.references :btc_withdraw_request
      t.references :fund_deposit_request
    end
  end

  def self.down
    create_table :btc_fund_transfers do |t|
      t.string :destination_btc_address
      t.decimal :amount, :precision => 15, :scale => 10
      t.references :user
      t.references :fund
      t.string :send_message
      t.string :status
      t.string :transaction_type
      t.string :description
      t.timestamps
    end
    drop_table :btc_withdraw_requests
    remove_column :fund_transaction_details, :status
    remove_column :fund_transaction_details, :message
    add_column :fund_transaction_details, :notes, :string
    remove_column :fund_transaction_details, :trade_id
    remove_column :fund_transaction_details, :btc_withdraw_request_id
    remove_column :fund_transaction_details, :fund_deposit_request_id    
  end
end
