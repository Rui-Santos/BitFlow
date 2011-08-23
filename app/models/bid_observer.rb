class BidObserver < ActiveRecord::Observer

  def after_create(bid)
    return if AppConfig.is?('SKIP_TRADE_CREATION', false)
    Bid.transaction(:requires_new => true) do 
      bid.user.debit_commission :bid_id => bid.id
      bid.user.usd.reserve!(bid.amount * bid.price)
      bid_amount_remaining = bid.amount_remaining
      bid.match.each do |ask|
        break if bid_amount_remaining == 0
        traded_price = ask.price
        traded_amount =  bid_amount_remaining >= ask.amount_remaining ? ask.amount_remaining : bid_amount_remaining

        trade = Trade.create!(ask: ask, bid: bid, market_price: traded_price, amount: traded_amount, status: Trade::Status::CREATED)
        bid.user.buy_btc(traded_price, traded_amount, trade, :amount_to_unreserve => bid.price * traded_amount)
        ask.user.sell_btc(traded_price, traded_amount, trade)
      
        bid_amount_remaining -= traded_amount
        ask.amount_remaining-= traded_amount
        ask.save!
      end

      bid.amount_remaining = bid_amount_remaining
      bid.save!
      if bid_amount_remaining !=0 && bid.market?
        puts "**************************"
        raise Order::Exceptions::Cancelled 
      end
    end
  end
end
