class UserObserver < ActiveRecord::Observer
  def after_create(user)
    user.funds = [Fund.new(:fund_type => Fund::Type::BTC), Fund.new(:fund_type => Fund::Type::USD)]
    user.token = user.id 
    user.secret = String.uuid
  end
  def before_create(user)
    user.referral_code = user.email + "77"

    puts "((((((((())))))))) #{user.referrer_code}" 
    unless user.referrer_code.blank?
      referrer = User.where(:referral_code => user.referrer_code).first
      referrer_usd_fund = referrer.funds.detect {|fund| fund.fund_type == 'USD'}
      user.referrer_fund_id = referrer_usd_fund.id
      puts "****** refferer_fund_id #{user.referrer_fund_id}"
    end
  end

  
end