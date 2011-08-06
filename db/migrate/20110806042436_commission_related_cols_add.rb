class CommissionRelatedColsAdd < ActiveRecord::Migration
  def self.up
    change_table :fund_transaction_details do |t|
      t.references :ask
      t.references :bid
    end
  end

  def self.down
    remove_column :fund_transaction_details, :ask_id
    remove_column :fund_transaction_details, :bid_id    
  end
end
