class AskObserver < ActiveRecord::Observer
  def after_create(ask)
    return if  AppConfig.is?('SKIP_TRADE_CREATION', false)

    ask.user.debit_commission :ask_id => ask.id
    seller_btc_fund = ask.user.btc
    seller_btc_fund.reserve!(ask.amount)
    ask_amount_remaining = ask.amount_remaining
    ask.match.each do |bid|
      break if ask_amount_remaining == 0.0
      traded_price = ask.price
      traded_amount  =  ask_amount_remaining >= bid.amount_remaining ? bid.amount_remaining : ask_amount_remaining

      trade = Trade.create(ask: ask, bid: bid, market_price: traded_price, amount: traded_amount, status: Trade::Status::CREATED)
      bid.user.buy_btc(traded_price, traded_amount, trade, :amount_to_unreserve => bid.price * traded_amount)
      ask.user.sell_btc(traded_price, traded_amount, trade)
      
      ask_amount_remaining -= traded_amount
      bid.update_attribute(:amount_remaining, bid.amount_remaining - traded_amount)
    end
    
    ask.amount_remaining = ask_amount_remaining
    ask.save
  end
end
