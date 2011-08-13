class AskObserver < ActiveRecord::Observer
  def before_create(ask)
    btc_fund = ask.user.btc
    usd_fund = ask.user.usd
    commission = ask.user.commission
    if ask.amount > btc_fund.available
      ask.errors.add(:base, "Not enough Bitcoin fund available")
      return false
    end
    if commission > usd_fund.available
      ask.errors.add(:base, "Not enough USD fund available")
      return false
    end
  end

  def after_create(ask)
    ask = ask.reload
    ask.user.debit_commission :ask_id => ask.id
    seller_btc_fund = ask.user.btc
    seller_btc_fund.reserve!(ask.amount)
    return if  AppConfig.is?('SKIP_TRADE_CREATION', false)
    seller_usd_fund = ask.user.usd
    ask_amount_remaining = ask.amount_remaining
   
    ask.match!.each do |bid|
      break if ask_amount_remaining == 0
      traded_price = 0.0
      traded_amount = 0.0
      if ask_amount_remaining >= bid.amount_remaining
        traded_price = ask.price
        traded_amount = bid.amount_remaining
      else
        traded_price = ask.price
        traded_amount = ask_amount_remaining
      end

      trade = Trade.create(ask: ask, bid: bid, market_price: traded_price, amount: traded_amount, status: Trade::Status::CREATED)
      buyer_usd_fund = bid.user.usd
      buyer_btc_fund = bid.user.btc
      
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
      
      ask_amount_remaining = ask_amount_remaining - traded_amount
      bid_amount_remaining = bid.amount_remaining - traded_amount
      
      if bid_amount_remaining == 0
        bid.update_attributes(:amount_remaining => bid_amount_remaining, :status => Order::Status::COMPLETE)
      else
        bid.update_attribute(:amount_remaining, bid_amount_remaining)
      end
    end
    
    ask.amount_remaining = ask_amount_remaining
    if ask.amount_remaining == 0
      ask.status = Order::Status::COMPLETE
    else
      ask.status = Order::Status::CANCELLED if ask.market?
    end
    ask.save
  end
end
