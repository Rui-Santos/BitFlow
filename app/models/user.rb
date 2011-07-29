class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_many :hosts
  has_many :bids
  has_many :asks
  has_many :funds
  has_many :bankaccounts

  after_create do |record| 
    record.funds = [Fund.new(:fund_type => 'BTC'), Fund.new(:fund_type => 'USD')]
  end  
end
