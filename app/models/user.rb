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
  has_many :fund_deposits
  has_one :user_wallet
  has_many :btc_fund_transfers

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
    Fund.find_btc(self.id)
  end

  def usd
    Fund.find_usd(self.id)
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
