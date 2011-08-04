class TradeApiController < ApiController
  before_filter :authenticate_api_user!
  def balance
    respond_to do |format|
      format.json { render :json => {:btc => @current_user.btc, :usd => @current_user.usd} }
    end
  end
  
  def orders
    respond_to do |format|
      format.json { render :json => Order.executed(current_user) }
    end
    
  end
  
  def bid
    @bid = Bid.new(:user_id => @current_user.id, 
                   :amount => params[:amount], 
                   :price => params[:price])
    if @bid.save
      head :created, :location => bid_path(@bid)
    else
      render :json  => @bid.errors
    end
  end
  
  def ask
    @ask = Ask.new(:user_id => @current_user.id, 
                   :amount => params[:amount], 
                   :price => params[:price])
    if @ask.save
      head :created, :location => ask_path(@ask)
    else
      render :json =>  @ask.errors
    end
  end
  
end