class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable, :timeoutable
  
  validates_uniqueness_of :referral_code, :allow_blank => true
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many :hosts
  has_many :bids
  has_many :asks
  has_many :funds
  has_many :bankaccounts
  has_many :fund_deposits
  has_one :user_wallet
  has_many :btc_fund_transfers

  def initialize(params)
    @referrer_code = params.delete(:referrer_code)
    super
  end

  def referrer_code
    @referrer_code
  end

  before_create do |user|
    user.referral_code = user.email + "77"

    unless @referrer_code.blank?
      referrer = User.where(:referral_code => @referrer_code).first
      referrer_usd_fund = referrer.funds.detect {|fund| fund.fund_type == 'USD'}
      user.referrer_fund_id = referrer_usd_fund.id
    end
  end

  after_create do |record| 
    record.funds = [Fund.new(:fund_type => 'BTC'), Fund.new(:fund_type => 'USD')]
  end

end
