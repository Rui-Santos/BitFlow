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
  
  
  def sell_btc(price, amount, trade, opt={})
    btc.unreserve!(opt[:amount_to_unreserve] || amount)

    defaults = {:tx_code => FundTransactionDetail::TransactionCode::BITCOIN_SOLD,
                :status => FundTransactionDetail::Status::PENDING,
                :user_id => self.id,
                :trade_id => trade.id,
                :ask_id => trade.ask.id,
                :bid_id => trade.bid.id}
                
    usd.credit! defaults.merge(:amount => (price * amount),:currency => 'USD')
    btc.debit! defaults.merge(:amount => amount,:currency => 'BTC')
  end
  
  def buy_btc(price, amount, trade, opt={})
    unreserve_amt = opt[:amount_to_unreserve] || amount * price
    
    usd.unreserve!(unreserve_amt)
    defaults = {:tx_code => FundTransactionDetail::TransactionCode::BITCOIN_PURCHASED,
                :status => FundTransactionDetail::Status::PENDING,
                :user_id => self.id,
                :trade_id => trade.id,
                :ask_id => trade.ask.id,
                :bid_id => trade.bid.id}

    usd.debit! defaults.merge(:amount => (price * amount), :currency => 'USD')
    btc.credit! defaults.merge(:amount => amount,:currency => 'BTC')
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
      referrer_credit = amount * (discount/100.0)
      admin_credit = amount - referrer_credit
      
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
      referrer_usd.credit! :amount => referrer_credit,
                          :tx_code => FundTransactionDetail::TransactionCode::COMMISSION,
                          :currency => 'USD',
                          :status => FundTransactionDetail::Status::COMMITTED,
                          :user_id => referrer_usd.user.id,
                          :ask_id => vals[:ask_id],
                          :bid_id => vals[:bid_id]
    end
  end
  
  def sync_with_bitcoind
    user_wallet.update_direct_receipts
    
    pending_trades = Trade.find_by_sql("select trades.* from trades inner join asks on trades.ask_id = asks.id inner join users on users.id = asks.user_id where trades.status = '#{Trade::Status::PENDING}' and users.id = #{id}")
    pending_trades.each {|trade| trade.update_transaction_details} if pending_trades
    
    pending_btc_withdraws = BtcWithdrawRequest.where(:status => BtcWithdrawRequest::Status::PENDING, :user_id => id)
    pending_btc_withdraws.each {|btc_withdraw| btc_withdraw.update_transaction_details} if pending_btc_withdraws
    
    created_trades = Trade.find_by_sql("select trades.* from trades inner join asks on trades.ask_id = asks.id inner join users on users.id = asks.user_id where trades.status = '#{Trade::Status::CREATED}' and users.id = #{id}")
    created_trades.each {|trade| trade.init_transactions} if created_trades
    
    created_btc_withdraws = BtcWithdrawRequest.where(:status => BtcWithdrawRequest::Status::CREATED, :user_id => id)
    created_btc_withdraws.each {|btc_withdraw| btc_withdraw.init_transactions} if created_btc_withdraws
  end
end
