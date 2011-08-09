class AddLastReceivedCol < ActiveRecord::Migration
  def self.up
    add_column :user_wallets, :last_received_epoch, :integer, :default => 0
  end

  def self.down
    remove_column :user_wallets, :last_received_epoch
  end
end
