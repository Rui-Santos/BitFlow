class CreateFunds < ActiveRecord::Migration
  def self.up
    create_table :funds do |t|
      t.string :fund_type
      t.decimal :amount, :precision => 15, :scale => 10
      t.decimal :reserved, :precision => 15, :scale => 10
      t.decimal :available, :precision => 15, :scale => 10
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :funds
  end
end
