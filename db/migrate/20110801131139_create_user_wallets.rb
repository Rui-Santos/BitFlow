class CreateUserWallets < ActiveRecord::Migration
  def self.up
    create_table :user_wallets do |t|
      t.string :name
      t.string :status
      t.string :address
      t.decimal :balance, :precision => 15, :scale => 10
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :user_wallets
  end
end
