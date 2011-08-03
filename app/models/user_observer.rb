class UserObserver < ActiveRecord::Observer
  def after_create(user)
    user.funds = [Fund.new(:fund_type => Fund::Type::BTC), Fund.new(:fund_type => Fund::Type::USD)]
    user.token = user.id 
    user.secret = String.uuid
  end
end