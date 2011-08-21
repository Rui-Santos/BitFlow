class AskObserver < ActiveRecord::Observer
  def after_create(ask)
    ask.user.debit_commission :ask_id => ask.id
    seller_btc_fund = ask.user.btc
    seller_btc_fund.reserve!(ask.amount)
    return if  AppConfig.is?('SKIP_TRADE_CREATION', false)
    seller_usd_fund = ask.user.usd
    ask_amount_remaining = ask.amount_remaining
   
    ask.match.each do |bid|
      break unless ask.active?
      traded_price = ask.price
      traded_amount  =  ask_amount_remaining >= bid.amount_remaining ? bid.amount_remaining : ask_amount_remaining

      trade = Trade.create(ask: ask, bid: bid, market_price: traded_price, amount: traded_amount, status: Trade::Status::CREATED)
      bid.user.buy_btc(traded_price, traded_amount, trade)
      ask.user.sell_btc(traded_price, traded_amount, trade)
      
      ask_amount_remaining = ask_amount_remaining - traded_amount
      bid_amount_remaining = bid.amount_remaining - traded_amount
      bid.update_attribute(:amount_remaining, bid_amount_remaining)
    end
    
    ask.amount_remaining = ask_amount_remaining
    ask.save
  end
end
