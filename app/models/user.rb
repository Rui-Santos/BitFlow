class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # , :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable, :timeoutable
  
  validates_uniqueness_of :referral_code, :allow_blank => true
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :referral_code

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
  def btc
    self.funds.detect {|f| f.fund_type == Fund::Type::BTC}
  end
  def usd
    self.funds.detect {|f| f.fund_type == Fund::Type::USD}
  end
  def full_commission?
    self.referrer_fund_id.nil? || self.referrer_fund_id == 0
  end
  def commission
    if full_commission?
      Setting.admin.data[:commission_fee]
    else
      settings = Setting.admin
      commission = settings.data[:commission_fee].to_f
      discount = settings.data[:referral_discount_percentage].to_f
      commission * ((100.0 - discount)/100.0)
    end
  end
  def debit_commission(vals)
    amount = commission
    if full_commission?
      usd.debit! :amount => amount,
                :tx_code => FundTransactionDetail::TransactionCode::COMMISSION,
                :currency => 'USD',
                :status => FundTransactionDetail::Status::COMMITTED,
                :user_id => self.id,
                :ask_id => vals[:ask_id],
                :bid_id => vals[:bid_id]
      AdminUser.usd.credit! :amount => amount,
                          :tx_code => FundTransactionDetail::TransactionCode::COMMISSION,
                          :currency => 'USD',
                          :status => FundTransactionDetail::Status::COMMITTED,
                          :user_id => AdminUser.id,
                          :ask_id => vals[:ask_id],
                          :bid_id => vals[:bid_id]
    else
      discount = Setting.admin.data[:referral_discount_percentage].to_f
      
      referrer_usd = Fund.find(referrer_fund_id)
      refferer_credit = amount * (discount/100.0)
      admin_credit = amount - refferer_credit
      
      usd.debit! :amount => amount,
                :tx_code => FundTransactionDetail::TransactionCode::COMMISSION,
                :currency => 'USD',
                :status => FundTransactionDetail::Status::COMMITTED,
                :user_id => self.id,
                :ask_id => vals[:ask_id],
                :bid_id => vals[:bid_id]
      AdminUser.usd.credit! :amount => admin_credit,
                          :tx_code => FundTransactionDetail::TransactionCode::COMMISSION,
                          :currency => 'USD',
                          :status => FundTransactionDetail::Status::COMMITTED,
                          :user_id => AdminUser.id,
                          :ask_id => vals[:ask_id],
                          :bid_id => vals[:bid_id]
      referrer_usd.credit! :amount => refferer_credit,
                          :tx_code => FundTransactionDetail::TransactionCode::COMMISSION,
                          :currency => 'USD',
                          :status => FundTransactionDetail::Status::COMMITTED,
                          :user_id => referrer_usd.user.id,
                          :ask_id => vals[:ask_id],
                          :bid_id => vals[:bid_id]
    end
  end
end
