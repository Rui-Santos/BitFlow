class AskObserver < ActiveRecord::Observer
  def after_create(ask)
    return if  AppConfig.is?('SKIP_TRADE_CREATION', false)
    Ask.transaction(:requires_new => true) do
      ask.user.debit_commission :ask_id => ask.id
      ask.user.btc.reserve!(ask.amount)
      ask_amount_remaining = ask.amount_remaining
      ask.match.each do |bid|
      break if ask_amount_remaining == 0.0
      traded_price = bid.price
      traded_amount = ask_amount_remaining >= bid.amount_remaining ? bid.amount_remaining : ask_amount_remaining

      trade = Trade.create(ask: ask, bid: bid, market_price: traded_price, amount: traded_amount, status: Trade::Status::CREATED)
      bid.user.buy_btc(traded_price, traded_amount, trade, :amount_to_unreserve => bid.price * traded_amount)
      ask.user.sell_btc(traded_price, traded_amount, trade)
      
      ask_amount_remaining -= traded_amount
      bid.update_attribute(:amount_remaining, bid.amount_remaining - traded_amount)
      
    end
      ask.amount_remaining = ask_amount_remaining
      ask.save
    
      if ask_amount_remaining !=0 && ask.market?
        Rails.logger.debug "**************************"
        Rails.logger.debug "Market Ask did not match bids. Cancelling."
        Rails.logger.debug "**************************"
        
        raise ActiveRecord::Rollback 
      end
    end
  end
  def after_rollback(ask)
    ask.reload.update_attribute(:status, Order::Status::CANCELLED) if ask.market?
  end

end
