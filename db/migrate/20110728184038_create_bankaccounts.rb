class CreateBankaccounts < ActiveRecord::Migration
  def self.up
    create_table :bankaccounts do |t|
      t.string :name
      t.integer :number
      t.references :user
      t.timestamps
    end
    
    add_index :bankaccounts, [:name, :number],                :unique => true
  end

  def self.down
    drop_table :bankaccounts
  end
end
