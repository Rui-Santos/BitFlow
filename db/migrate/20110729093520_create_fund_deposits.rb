class CreateFundDeposits < ActiveRecord::Migration
  def self.up
    create_table :fund_deposits do |t|
      t.decimal :amount, :precision => 15, :scale => 10
      t.references :bankaccount
      t.references :user
      t.string :status
      t.timestamps
      t.string :currency
    end

    add_column :bankaccounts, :status, :string
    change_column :bankaccounts, :number, :string

    remove_index :bankaccounts, [:name, :number]
  end

  def self.down
    drop_table :fund_deposits

    remove_column :bankaccounts, :status
    change_column :bankaccounts, :number, :integer

    add_index :bankaccounts, [:name, :number],                :unique => true
  end
end
