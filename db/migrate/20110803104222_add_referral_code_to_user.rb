class AddReferralCodeToUser < ActiveRecord::Migration
  def self.up
  	remove_column :users, :bitcoin_address
  	add_column :users, :referral_code, :string
  	add_column :users, :referrer_fund_id, :integer

    User.all.each {|usr| usr.update_attribute(:referral_code, usr.email + "77") unless usr.referral_code}
  end

  def self.down
  	remove_column :users, :referral_code
  	add_column :users, :bitcoin_address, :string
  	remove_column :users, :referrer_fund_id
  end
end
