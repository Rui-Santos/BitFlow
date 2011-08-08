class BidObserver < ActiveRecord::Observer
  def before_create(bid)
    usd_fund = bid.user.usd
    total_bid_amount = bid.amount * bid.price
    commission = bid.user.commission
    if (total_bid_amount + commission) > usd_fund.available
      bid.errors.add(:base, "Not enough USD fund available")
      return false
    end
  end
  def after_create(bid)
    bid = bid.reload
    bid.user.debit_commission :bid_id => bid.id
    buyer_usd_fund = bid.user.usd
    buyer_usd_fund.reserve!(bid.amount * bid.price)
    return if AppConfig.is?('SKIP_TRADE_CREATION', false)
    buyer_btc_fund = bid.user.btc
    bid_amount_remaining = bid.amount_remaining
    bid.match!.each do |ask|
      break if bid_amount_remaining == 0
      traded_price = 0.0;
      traded_amount = 0.0;
      if bid_amount_remaining >= ask.amount_remaining
        traded_price = ask.price
        traded_amount = ask.amount_remaining
      else
        traded_price = ask.price
        traded_amount = bid_amount_remaining
      end
      trade = Trade.create(ask: ask, bid: bid, market_price: traded_price, amount: traded_amount)
      buyer_usd_fund.unreserve!(bid.price * traded_amount)
      buyer_usd_fund.debit! :amount => (traded_price * traded_amount),
                            :tx_code => FundTransactionDetail::TransactionCode::BITCOIN_PURCHASED,
                            :currency => 'USD',
                            :status => FundTransactionDetail::Status::PENDING,
                            :user_id => bid.user.id,
                            :trade_id => trade.id,
                            :ask_id => ask.id,
                            :bid_id => bid.id
      buyer_btc_fund.credit! :amount => traded_amount,
                            :tx_code => FundTransactionDetail::TransactionCode::BITCOIN_PURCHASED,
                            :currency => 'BTC',
                            :status => FundTransactionDetail::Status::PENDING,
                            :user_id => bid.user.id,
                            :trade_id => trade.id,
                            :ask_id => ask.id,
                            :bid_id => bid.id
      seller_usd_fund = ask.user.usd
      seller_btc_fund = ask.user.btc
      seller_btc_fund.unreserve!(traded_amount)
      seller_usd_fund.credit! :amount => (traded_price * traded_amount),
                              :tx_code => FundTransactionDetail::TransactionCode::BITCOIN_SOLD,
                              :currency => 'USD',
                              :status => FundTransactionDetail::Status::PENDING,
                              :user_id => ask.user.id,
                              :trade_id => trade.id,
                              :ask_id => ask.id,
                              :bid_id => bid.id
      seller_btc_fund.debit! :amount => traded_amount,
                              :tx_code => FundTransactionDetail::TransactionCode::BITCOIN_SOLD,
                              :currency => 'BTC',
                              :status => FundTransactionDetail::Status::PENDING,
                              :user_id => ask.user.id,
                              :trade_id => trade.id,
                              :ask_id => ask.id,
                              :bid_id => bid.id
      bid_amount_remaining = bid_amount_remaining - traded_amount
      ask_amount_remaining = ask.amount_remaining - traded_amount
      if ask_amount_remaining == 0
        ask.update_attributes(:amount_remaining => ask_amount_remaining, :status => Order::Status::COMPLETE)
      else
        ask.update_attribute(:amount_remaining, ask_amount_remaining)
      end
      # tx_id = BitcoinProxy.send_from(ask.user.user_wallet.name, bid.user.user_wallet.address, traded_amount, "trade #{trade.id}", "trade #{trade.id}")
      # trade.update_attribute(:btc_tx_id, tx_id)
    end
    bid.amount_remaining = bid_amount_remaining
    bid.status = Order::Status::COMPLETE if bid.amount_remaining == 0
    bid.save
  end
end
