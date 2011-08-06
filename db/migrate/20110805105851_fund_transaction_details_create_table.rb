class FundTransactionDetailsCreateTable < ActiveRecord::Migration
  def self.up
    rename_table :fund_deposits, :fund_deposit_requests
    create_table :fund_transaction_details do |t|
      t.decimal :amount, :precision => 15, :scale => 10
      t.string :tx_type
      t.string :notes
      t.references :user
      t.references :fund
      t.string :tx_code
      t.string :currency
      t.timestamps
    end
  end

  def self.down
    drop_table :fund_transaction_details
    rename_table :fund_deposit_requests, :fund_deposits
  end
end
