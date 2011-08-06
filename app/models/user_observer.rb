class UserObserver < ActiveRecord::Observer
  def before_create(user)
    user.referral_code = user.email + "77"

    unless user.referrer_code.blank?
      referrer = User.where(:referral_code => user.referrer_code).first
      referrer_usd_fund = referrer.funds.detect {|fund| fund.fund_type == 'USD'}
      user.referrer_fund_id = referrer_usd_fund.id
    end
  end
  def after_create(user)
    user.funds = [Fund.new(:fund_type => Fund::Type::BTC), Fund.new(:fund_type => Fund::Type::USD)]
    user.token = user.id 
    user.secret = String.uuid
    begin
      address = BitcoinProxy.new_address(user.email)
      user_wallet = UserWallet.new :name => user.email, 
                                    :status => UserWallet::Status::ACTIVE, 
                                    :address => address, 
                                    :balance => 0.0, 
                                    :user_id => user.id
      unless user_wallet.save
        user.errors.add(:base, 'Error in Wallet creation')
        return false
      end
    rescue => e
      user.errors.add(:base, "Error in Bitcoin Address creation: #{e.inspect}")
      return false
    end
  end
end