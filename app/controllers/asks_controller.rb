class AsksController < ApplicationController

  def index
    @asks = current_user.asks
  end

  def show
    @ask = Ask.find(params[:id])
  end

  def new
    @ask = Ask.new
  end

  def create
    @ask = Ask.new(:user_id => current_user.id, 
                   :amount => params[:ask][:amount], 
                   :price => params[:ask][:price], 
                   :status => Order::Status::ACTIVE)

    respond_to do |format|
      if @ask.save
        format.html { redirect_to(orders_url, :notice => 'Ask was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def destroy
    @ask = Ask.find(params[:id])
    @ask.update_attribute :status, Order::Status::CANCELLED
    Fund.update_seller_btc_fund_on_cancel @ask
    respond_to do |format|
      format.html { redirect_to(orders_url) }
      format.xml  { head :ok }
    end
  end
end
