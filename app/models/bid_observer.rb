class BidObserver < ActiveRecord::Observer

  def after_create(bid)
    bid.user.debit_commission :bid_id => bid.id
    bid.user.usd.reserve!(bid.amount * bid.order_price)

    return if AppConfig.is?('SKIP_TRADE_CREATION', false)

    bid_amount_remaining = bid.amount_remaining
    bid.match.each do |ask|
      break unless active?
      traded_price = ask.price
      traded_amount =  bid_amount_remaining >= ask.amount_remaining ? ask.amount_remaining : bid_amount_remaining

      trade = Trade.create(ask: ask, bid: bid, market_price: traded_price, amount: traded_amount, status: Trade::Status::CREATED)
      bid.user.buy_btc(traded_price, traded_amount, trade, :amount_to_unreserve => bid.order_price * traded_amount)

      ask.user.sell_btc(traded_price, traded_amount, trade)
      
      bid_amount_remaining -= traded_amount
      ask.update_attribute(:amount_remaining, ask.amount_remaining - traded_amount)
    end

    bid.amount_remaining = bid_amount_remaining
    bid.save
  end
end
