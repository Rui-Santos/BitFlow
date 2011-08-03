class TradeApiController < ApiController
  before_filter :authenticate_api_user!
  def balance
    respond_to do |format|
      format.json do 
        render :json => {:btc => @current_user.btc, :usd => @current_user.usd}
      end
    end
    
  end
  
  def orders
    
  end
  
  def buy
    
  end
  
  def sell
    
  end
  
  def cancel
    
  end
end