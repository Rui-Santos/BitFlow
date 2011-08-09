 class AsksController < ApplicationController
  def index
    @asks = current_user.asks
  end

  def show
    @ask = Ask.find(params[:id])
  end

  def new
    @ask = Ask.new(:order_type => params[:type])
  end

  def create
    @ask = Ask.new(:user_id => current_user.id, 
                    :amount => params[:ask][:amount], 
                    :price => params[:ask][:price],
                    :amount_remaining => params[:ask][:amount],
                    :status => Order::Status::ACTIVE, 
                    :order_type => params[:ask][:order_type])
    respond_to do |format|
      if @ask.save
        format.html { redirect_to(orders_url, :notice => 'Ask was successfully created.') }
        format.json { head  :created, :location => ask_path(@ask)}
      else
        format.html { render :action => :new }
        format.json { render :json => @ask.errors }
      end
    end
  end

  def destroy
    Order.transaction do
      @ask = Ask.find(params[:id])
      authorised_block(@ask) do
        @ask.update_attribute :status, Order::Status::CANCELLED
        @ask.user.btc.unreserve!(@ask.amount_remaining)
      end
    end
    respond_to do |format|
      format.html { redirect_to(:back) }
      format.json { head :ok }
    end
  end
end
