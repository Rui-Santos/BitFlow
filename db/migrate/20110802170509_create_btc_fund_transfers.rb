class CreateBtcFundTransfers < ActiveRecord::Migration
  def self.up
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
  end

  def self.down
    drop_table :btc_fund_transfers
  end
end
