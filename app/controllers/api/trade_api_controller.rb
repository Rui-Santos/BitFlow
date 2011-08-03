class TradeApiController < ApiController
  before_filter :authenticate_api_user!
  def balance
    respond_to do |format|
      format.json do 
        render :json => {:btc => {:available => 0 , :total => 0, :reserved => 0}, :usd => {:available => 0, :total => 0, :reserved => 0}}
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