class BidsController < ApplicationController

  def index
    @bids = current_user.bids.all
  end

  def show
    @bid = Bid.find(params[:id])
  end

  def new
    @bid = Bid.new
  end

  def create
    order_type = params[:ask][:order_type] || Order::Type::LIMIT
    @bid = Bid.new(:user_id => current_user.id, 
                    :amount => params[:bid][:amount], 
                    :price => params[:bid][:price], 
                    :amount_remaining => params[:bid][:amount],
                    :status => Order::Status::ACTIVE,
                    :order_type => order_type)

    respond_to do |format|
      if @bid.save
        format.html { redirect_to(orders_url, :notice => 'Bid was successfully created.') }
        format.json { head :created, :location => bid_path(@bid)}
      else
        format.html { render :action => "new" }
        format.json { render :json => @bid.errors }
      end
    end
  end
  
  def destroy
    Order.transaction do
      @bid = Bid.find(params[:id])
      authorised_block(@bid) do 
        @bid.update_attribute :status, Order::Status::CANCELLED
        @bid.user.usd.unreserve!(@bid.amount_remaining * @bid.price)
      end
    end
    respond_to do |format|
      format.html { redirect_to(:back) }
      format.json  { head :ok }
    end
  end
end
