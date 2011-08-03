class UserObserver < ActiveRecord::Observer
  def after_create(user)
    user.funds = [Fund.new(:fund_type => 'BTC'), Fund.new(:fund_type => 'USD')]
    user.token = user.id 
    user.secret = String.uuid
  end
end