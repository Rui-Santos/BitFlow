class AddNameAdminBitcoinAddressToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :admin, :boolean, :default => false
    add_column :users, :name, :string, :length => 256
    add_column :users, :bitcoin_address, :string
  end

  def self.down
    remove_column :users, :address
    remove_column :users, :name
    remove_column :users, :admin
  end
end
