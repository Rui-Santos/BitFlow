FactoryGirl.define do
  factory :user do
    name 'John'
    sequence(:email) {|n| "person#{n}@example.com" }
    admin false
    password '1234fba1'
  end

  factory :fund do
    amount 100
    available 100
  end

  factory :admin, :class => User do
    name 'Admin'
    sequence(:email) { |n| "admin#{n}@example.com"}
    admin true
    password '1234fba1'
  end

  factory :admin_setting, :class => Setting do
    setting_type 'admin'
    data :minimum_commission_fee => 0.50, :daily_withdrawal_limit => 10000,:monthly_withdrawal_limit =>  10000,:circuit_breaker_change_percent => 5, :circuit_breaker_change_period => 8.hours
  end

  factory :ask, :class => Ask do
    price 100.78
    amount 10
    status 'active'
    user
  end

  factory :bid,:class=>Bid do
    price 100.78
    amount 10
    amount_remaining 10
    status 'active'
    user
  end
end