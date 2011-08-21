FactoryGirl.define do
  factory :user do
    name 'John'
    sequence(:email) {|n| "person#{n}@example.com" }
    admin false
    password '1234fba1'
    after_build { |user| user.funds = [Factory(:btc_fund), Factory(:usd_fund)]}
  end

  factory :fund do
    amount 100
    available 100
  end

  factory :usd_fund, :class => Fund do
    amount 10000
    available 100
    fund_type 'USD'
  end

  factory :btc_fund, :class => Fund do
    amount 10000
    available 100
    fund_type 'BTC'
  end

  factory :admin, :class => User do
    name 'Admin'
    sequence(:email) { |n| "admin#{n}@example.com"}
    admin true
    password '1234fba1'
    after_build { |admin| admin.funds = [Factory(:btc_fund), Factory(:usd_fund)]}
    
  end

  factory :admin_setting, :class => Setting do
    setting_type 'admin'
    data :commission_fee => 0.50, :daily_withdrawal_limit => 10000,:monthly_withdrawal_limit =>  10000,:circuit_breaker_change_percent => 5, :circuit_breaker_change_period => 8.hours
  end

  factory :ask, :class => Ask do
    price 100.78
    amount 10
    status 'active'
    order_type Order::Type::LIMIT
    user
  end

  factory :bid,:class=>Bid do
    price 100.78
    amount 10
    amount_remaining 10
    order_type Order::Type::LIMIT
    status 'active'
    user
  end
end