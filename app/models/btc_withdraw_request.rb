class BtcWithdrawRequest < ActiveRecord::Base
	belongs_to :user

	validates_presence_of :destination_btc_address, :amount, :message
  validates_numericality_of :amount, :greater_than => 0.0

  module Status
    CREATED = :created
    PENDING = :pending
    COMPLETE = :complete
  end
  
  def init_transactions
    if status == BtcWithdrawRequest::Status::CREATED
      BtcWithdrawRequest.transaction do
        update_attribute :status, BtcWithdrawRequest::Status::PENDING
        
        puts "BtcWithdrawRequest[#{id}] status -> PENDING"
        
        btc_tx_id = BitcoinProxy.send_from(user.user_wallet.name, 
                              destination_btc_address, 
                              amount, 
                              "bf-withdraw #{id}",
                              "bf-withdraw #{id}")
                              
        puts "Posted BtcWithdrawRequest[#{id}] on bitcoind"
        
        update_attribute :btc_tx_id, btc_tx_id
        
        puts "BtcWithdrawRequest[#{id}] btc_tx_id -> #{btc_tx_id}"
      end
    end
  end

  def update_transaction_details
    if status == BtcWithdrawRequest::Status::PENDING
      if btc_tx_id
        tx_details = BitcoinProxy.get_transaction btc_tx_id
      
        puts "BtcWithdrawRequest[#{id}] :: fetched transaction details from bitcoind for btc_tx_id: #{btc_tx_id} => #{tx_details}"
      
        _update_transaction_details tx_details
      else
        puts "BtcWithdrawRequest[#{id}] :: NO BTC_TX_ID found!!!!"
      
        all_tx_details = BitcoinProxy.list_transactions(user.user_wallet.name, 25)
        comment = "bf-withdraw #{id}"
        tx_details = all_tx_details.detect do |x_det|
          x_det["category"] == 'send' && x_det["comment"] == comment && x_det["to"] == comment
        end
    
        puts "BtcWithdrawRequest[#{id}] :: Extracted transaction details from comments =>  #{tx_details}"
    
        _update_transaction_details tx_details
      end
    end
  end
  
  private
  def _update_transaction_details(tx_details)
    confirmations = tx_details["confirmations"].to_f
    if confirmations > 5
      BtcWithdrawRequest.transaction do
        update_attribute :status, BtcWithdrawRequest::Status::COMPLETE
        user.btc.unreserve!(amount)
        user.btc.debit! :amount => amount,
                        :tx_code => FundTransactionDetail::TransactionCode::PAYMENT_SENT,
                        :currency => 'BTC',
                        :status => FundTransactionDetail::Status::COMMITTED,
                        :message => message,
                        :user_id => user_id,
                        :btc_withdraw_request_id => id
                                                      
        puts "BtcWithdrawRequest[#{id}] :: Updated Status->COMPLETE, unreserved, Debitted amount"

        fee = tx_details["fee"].try(:to_f).try(:abs)
        if fee && fee > 0.0
            user.btc.debit! :amount => fee,
                            :tx_code => FundTransactionDetail::TransactionCode::BITCOIN_FEE,
                            :currency => 'BTC',
                            :status => FundTransactionDetail::Status::COMMITTED,
                            :user_id => user_id,
                            :btc_withdraw_request_id => id
            puts "BtcWithdrawRequest[#{id}] :: bitcoind demanded a fee of #{fee}!!!"
        end
      end
    end
  end
end
