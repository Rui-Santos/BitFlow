class BitcoindSyncher
  
  def self.check_btc_received_on_bitcoind
    wallets = UserWallet.where(:status => UserWallet::Status::ACTIVE)
    wallets.each do |wallet|
      last_received_epoch = wallet.last_received_epoch
      all_tx_details = BitcoinProxy.list_transactions(wallet.name, 100)
      all_tx_details.each do |tx_details|
        category = tx_details["category"]
        time = tx_details["time"].to_i
        confirmations = tx_details["confirmations"].to_i
        if category == 'receive' && time >= last_received_epoch && confirmations > 5
          comment = tx_details["comment"]
          to = tx_details["to"]
          if (comment.nil? && to.nil?) || 
              (comment && !comment.start_with?("bf-withdraw") && !comment.start_with?("bf-trade") &&
              to && !to.start_with?("bf-withdraw") && !to.start_with?("bf-trade"))
            UserWallet.transaction do
              amount = tx_details["amount"].to_f
              wallet.user.btc.credit! :amount => amount,
                                      :tx_code => FundTransactionDetail::TransactionCode::PAYMENT_RECEIVED,
                                      :currency => 'BTC',
                                      :status => FundTransactionDetail::Status::COMMITTED,
                                      :user_id => wallet.user.id
              wallet.update_attribute :last_received_epoch, time
              last_received_epoch = time
            end
          end
        end
      end
    end
  end
  
  def self.initiate_withdraw_on_bitcoind
    created_btc_withdraw_requests = BtcWithdrawRequest.where(:status => BtcWithdrawRequest::Status::CREATED)
    if created_btc_withdraw_requests
      created_btc_withdraw_requests.each do |created_btc_withdraw_request|
        BtcWithdrawRequest.transaction do
          created_btc_withdraw_request.update_attribute :status, BtcWithdrawRequest::Status::PENDING
          btc_tx_id = BitcoinProxy.send_from(created_btc_withdraw_request.user.user_wallet.name, 
                                created_btc_withdraw_request.destination_btc_address, 
                                created_btc_withdraw_request.amount, 
                                "bf-withdraw #{created_btc_withdraw_request.id}",
                                "bf-withdraw #{created_btc_withdraw_request.id}")
          created_btc_withdraw_request.update_attribute :btc_tx_id, btc_tx_id
        end
      end
    end
  end
  
  def self.check_btc_withdraw_status_on_bitcoind
    pending_btc_withdraw_requests = BtcWithdrawRequest.where(:status => BtcWithdrawRequest::Status::PENDING)
    if pending_btc_withdraw_requests
      pending_btc_withdraw_requests.each do |pending_btc_withdraw_request|
        btc_tx_id = pending_btc_withdraw_request.btc_tx_id
        if btc_tx_id
          tx_details = BitcoinProxy.get_transaction btc_tx_id
          complete_btc_withdraw_request tx_details, pending_btc_withdraw_request
        else
          all_tx_details = BitcoinProxy.list_transactions(pending_btc_withdraw_request.user.user_wallet.name, 25)
          comment = "bf-withdraw #{pending_btc_withdraw_request.id}"
          tx_details = all_tx_details.detect do |x_det|
            x_det["category"] == 'send' && x_det["comment"] == comment && x_det["to"] == comment
          end
          complete_btc_withdraw_request tx_details, pending_btc_withdraw_request
        end
      end
    end
  end
  
  def self.complete_btc_withdraw_request(tx_details, pending_btc_withdraw_request)
    confirmations = tx_details["confirmations"].to_f
    if confirmations > 5
      BtcWithdrawRequest.transaction do
        pending_btc_withdraw_request.update_attribute :status, BtcWithdrawRequest::Status::COMPLETE
        pending_btc_withdraw_request.user.btc.unreserve!(pending_btc_withdraw_request.amount)
        pending_btc_withdraw_request.user.btc.debit! :amount => pending_btc_withdraw_request.amount,
                                                      :tx_code => FundTransactionDetail::TransactionCode::PAYMENT_SENT,
                                                      :currency => 'BTC',
                                                      :status => FundTransactionDetail::Status::COMMITTED,
                                                      :message => pending_btc_withdraw_request.message,
                                                      :user_id => pending_btc_withdraw_request.user_id,
                                                      :btc_withdraw_request_id => pending_btc_withdraw_request.id
        fee = tx_details["fee"].try(:to_f).try(:abs)
        if fee && fee > 0.0
            pending_btc_withdraw_request.user.btc.debit! :amount => fee,
                                                          :tx_code => FundTransactionDetail::TransactionCode::BITCOIN_FEE,
                                                          :currency => 'BTC',
                                                          :status => FundTransactionDetail::Status::COMMITTED,
                                                          :user_id => pending_btc_withdraw_request.user_id,
                                                          :btc_withdraw_request_id => pending_btc_withdraw_request.id
        end
      end
    end
  end
  
  def self.initiate_trade_btc_transfer_on_bitcoind
    trades = Trade.where(:status => Trade::Status::CREATED)
    if trades
      trades.each do |trade|
        Trade.transaction do
          trade.update_attribute :status, Trade::Status::PENDING
          btc_tx_id = BitcoinProxy.send_from(trade.ask.user.user_wallet.name, 
                                trade.bid.user.user_wallet.address, 
                                trade.amount, 
                                "bf-trade #{trade.id}",
                                "bf-trade #{trade.id}")
          trade.update_attribute :btc_tx_id, btc_tx_id
        end
      end
    end
  end
  
  def self.check_btc_trade_status_on_bitcoind
    pending_trade_requests = Trade.where(:status => Trade::Status::PENDING)
    if pending_trade_requests
      pending_trade_requests.each do |pending_trade_request|
        btc_tx_id = pending_trade_request.btc_tx_id
        if btc_tx_id
          tx_details = BitcoinProxy.get_transaction btc_tx_id
          complete_btc_trade_request tx_details, pending_trade_request
        else
          all_tx_details = BitcoinProxy.list_transactions(pending_trade_request.ask.user.user_wallet.name, 25)
          comment = "bf-trade #{pending_trade_request.id}"
          tx_details = all_tx_details.detect do |x_det|
            x_det["category"] == 'send' && x_det["comment"] == comment && x_det["to"] == comment
          end
          complete_btc_trade_request tx_details, pending_trade_request
        end
      end
    end
  end
  
  def self.complete_btc_trade_request(tx_details, pending_trade_request)
    confirmations = tx_details["confirmations"].to_f
    if confirmations > 5
      Trade.transaction do
        pending_trade_request.update_attribute :status, Trade::Status::COMPLETE
        all_pending_tx_details = FundTransactionDetail.where(:trade_id  => pending_trade_request.id)
        all_pending_tx_details.each {|tx_detail| tx_detail.update_attribute :status, FundTransactionDetail::Status::COMMITTED}
        fee = tx_details["fee"].try(:to_f).try(:abs)
        if fee && fee > 0.0
          pending_trade_request.ask.user.btc.debit! :amount => fee,
                                                  :tx_code => FundTransactionDetail::TransactionCode::BITCOIN_FEE,
                                                  :currency => 'BTC',
                                                  :status => FundTransactionDetail::Status::COMMITTED,
                                                  :user_id => pending_trade_request.ask.user.id,
                                                  :trade_id => pending_trade_request.id,
                                                  :ask_id => pending_trade_request.ask.id,
                                                  :bid_id => pending_trade_request.bid.id
        end
      end
    end
  end
  
  
end