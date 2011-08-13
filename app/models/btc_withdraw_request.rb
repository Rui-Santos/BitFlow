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
    if status == BtcWithdrawRequest::Status::CREATED.to_s
      BtcWithdrawRequest.transaction do
        btc_tx_id = BitcoinProxy.send_from(user.user_wallet.name, 
                              destination_btc_address, 
                              amount + 0.0,
                              "bf-withdraw #{id}",
                              "bf-withdraw #{id}",
                              5)
        update_attributes :status => BtcWithdrawRequest::Status::PENDING,
                          :btc_tx_id => btc_tx_id
      end
    end
  end

  def update_transaction_details
    if status == BtcWithdrawRequest::Status::PENDING.to_s
      if btc_tx_id
        tx_details = BitcoinProxy.get_transaction btc_tx_id
        _update_transaction_details tx_details
      else
        all_tx_details = BitcoinProxy.list_transactions(user.user_wallet.name, 25)
        comment = "bf-withdraw #{id}"
        tx_details = all_tx_details.detect do |x_det|
          x_det["category"] == 'send' && x_det["comment"] == comment && x_det["to"] == comment
        end
        _update_transaction_details tx_details
      end
    end
  end
  
  private
  def _update_transaction_details(tx_details)
    confirmations = tx_details["confirmations"].to_f
    if confirmations >= 5
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
        fee = tx_details["fee"].try(:to_f).try(:abs)
        if fee && fee > 0.0
            user.btc.debit! :amount => fee,
                            :tx_code => FundTransactionDetail::TransactionCode::BITCOIN_FEE,
                            :currency => 'BTC',
                            :status => FundTransactionDetail::Status::COMMITTED,
                            :user_id => user_id,
                            :btc_withdraw_request_id => id
        end
      end
    end
  end
end
