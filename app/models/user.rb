class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # , :encryptable, :confirmable, :lockable, :timeoutable
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
  has_one :user_wallet

  def initialize(params =nil)
    @referrer_code = params.delete(:referrer_code) if params
    super(params)
  end
  def referrer_code
    @referrer_code
  end
  def referral_code_unused?
    User.where(:referrer_fund_id => usd.id).first.nil?
  end
  def btc
    self.funds.detect {|f| f.fund_type == Fund::Type::BTC}
  end
  def usd
    self.funds.detect {|f| f.fund_type == Fund::Type::USD}
  end
  def undiscounted_commission?
    self.referrer_fund_id.nil? || self.referrer_fund_id == 0 || referral_code_unused?
  end
  def commission
    if undiscounted_commission?
      Setting.admin.data[:commission_fee]
    else
      settings = Setting.admin
      commission = settings.data[:commission_fee]
      discount = settings.data[:referral_discount_percentage]
      commission * ((100 - discount)/100)
    end
  end
end
