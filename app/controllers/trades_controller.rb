class TradesController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:price_graph, :market_price]

  def index
    @trades = Order.executed(current_user)
  end

  def show
    @trade = Trade.find(params[:id])
  end

  def price_graph
    trades = Trade.select([:updated_at, :amount, :market_price]).order("updated_at asc").limit(200)
    respond_to do |format|
      format.js { render :json => trades }
    end
  end

  def market_price
    render :json => {:last_trade => Trade.latest_market_price}
  end
end
