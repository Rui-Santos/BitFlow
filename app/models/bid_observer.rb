class BidObserver < ActiveRecord::Observer

  def after_create(bid)
    bid.user.debit_commission :bid_id => bid.id
    bid.user.usd.reserve!(bid.amount * bid.order_price)

    return if AppConfig.is?('SKIP_TRADE_CREATION', false)

    bid_amount_remaining = bid.amount_remaining
    bid.match.each do |ask|
      break if bid_amount_remaining == 0
      traded_price = ask.price
      traded_amount =  bid_amount_remaining >= ask.amount_remaining ? ask.amount_remaining : bid_amount_remaining

      trade = Trade.create(ask: ask, bid: bid, market_price: traded_price, amount: traded_amount, status: Trade::Status::CREATED)
      bid.user.buy_btc(traded_price, traded_amount, trade)
      #Something not right here.
      # takl to niket
      # buyer_usd_fund.unreserve!(bid.order_price * traded_amount)
      #       buyer_usd_fund.debit! :amount => (traded_price * traded_amount),
      #                             :tx_code => FundTransactionDetail::TransactionCode::BITCOIN_PURCHASED,
      #                             :currency => 'USD',
      #                             :status => FundTransactionDetail::Status::PENDING,
      #                             :user_id => bid.user.id,
      #                             :trade_id => trade.id,
      #                             :ask_id => ask.id,
      #                             :bid_id => bid.id
      #       buyer_btc_fund.credit! :amount => traded_amount,
      #                             :tx_code => FundTransactionDetail::TransactionCode::BITCOIN_PURCHASED,
      #                             :currency => 'BTC',
      #                             :status => FundTransactionDetail::Status::PENDING,
      #                             :user_id => bid.user.id,
      #                             :trade_id => trade.id,
      #                             :ask_id => ask.id,
      #                             :bid_id => bid.id
      ask.user.sell_btc(traded_price, traded_amount, trade)
      
      bid_amount_remaining -= traded_amount
      ask_amount_remaining = ask.amount_remaining - traded_amount
      ask.update_attribute(:amount_remaining, ask_amount_remaining)
    end
    bid.amount_remaining = bid_amount_remaining
    bid.save
  end
end
