class Trade < ActiveRecord::Base
  belongs_to :ask
  belongs_to :bid
  has_many :fund_transaction_details

  scope :user_transactions, lambda { |user|
    joins([:bids, :asks]).where('bids.user_id = ? and asks.user_id = ?', user.id, user.id).order(:updated_at).reverse_order
  }

  # def amount
  #   bid.amount
  # end

  def sold
    ask.amount.round(2)
  end

  def bought
    bid.amount.round(2)
  end
  
  module Status
    CREATED = :created
    PENDING = :pending
    COMPLETE = :complete
  end
  
  def init_transactions
    if Trade::Status::CREATED
      Trade.transaction do
        update_attribute :status, Trade::Status::PENDING
        
        puts "Trade[#{id}] status -> PENDING"
        
        btc_tx_id = BitcoinProxy.send_from(ask.user.user_wallet.name, 
                              bid.user.user_wallet.address, 
                              trade.amount, 
                              "bf-trade #{id}",
                              "bf-trade #{id}",
                              5)
                              
        puts "Posted Trade[#{id}] on bitcoind"
        
        update_attribute :btc_tx_id, btc_tx_id
        
        puts "Trade[#{id}] btc_tx_id -> #{btc_tx_id}"
      end
    end
  end

  def update_transaction_details
    if status == Trade::Status::PENDING
      if btc_tx_id
        tx_details = BitcoinProxy.get_transaction btc_tx_id
      
        puts "Trade[#{id}] :: fetched transaction details from bitcoind for btc_tx_id: #{btc_tx_id} => #{tx_details}"
      
        _update_transaction_details tx_details
      else
        puts "Trade[#{trade.id}] :: NO BTC_TX_ID found!!!!"
      
        all_tx_details = BitcoinProxy.list_transactions(ask.user.user_wallet.name, 25)
        comment = "bf-trade #{id}"
        tx_details = all_tx_details.detect do |x_det|
          x_det["category"] == 'send' && x_det["comment"] == comment && x_det["to"] == comment
        end
        puts "Trade[#{id}] :: Extracted transaction details from comments =>  #{tx_details}"
      
        _update_transaction_details tx_details
      end
    end
  end
  
  private
  def _update_transaction_details(tx_details)
    confirmations = tx_details["confirmations"].to_f
    if confirmations > 5
      Trade.transaction do
        update_attribute :status, Trade::Status::COMPLETE
        
        fund_transaction_details.each {|tx_detail| tx_detail.update_attribute :status, FundTransactionDetail::Status::COMMITTED}
        
        puts "Trade[#{id}] :: Updated Status->COMPLETE, Updated of all pending trade tx details Status->COMMITTED"
        
        fee = tx_details["fee"].try(:to_f).try(:abs)
        if fee && fee > 0.0
          ask.user.btc.debit! :amount => fee,
                              :tx_code => FundTransactionDetail::TransactionCode::BITCOIN_FEE,
                              :currency => 'BTC',
                              :status => FundTransactionDetail::Status::COMMITTED,
                              :user_id => ask.user.id,
                              :trade_id => id,
                              :ask_id => ask.id,
                              :bid_id => bid.id
                              
          puts "Trade[#{id}] :: bitcoind demanded a fee of #{fee}!!!"
        end
      end
    end
  end
end
