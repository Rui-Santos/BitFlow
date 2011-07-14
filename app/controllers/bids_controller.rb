class BidsController < ApplicationController
  def index
    @bids = current_user.bids.all
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @bid = Bid.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @bid = Bid.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @bid = Bid.find(params[:id])
  end

  def create
    @bid = Bid.new(:user_id => current_user.id, 
                   :amount => params[:bid][:amount].to_f, 
                   :price => params[:bid][:price].to_f, 
                   :status => Order::Status::ACTIVE)

    respond_to do |format|
      if @bid.save
        format.html { redirect_to(@bid, :notice => 'Bid was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @bid = Bid.find(params[:id])
  
    respond_to do |format|
      if @bid.update_attributes(params[:bid])
        format.html { redirect_to(@bid, :notice => 'Bid was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  # 
  # # DELETE /bids/1
  # # DELETE /bids/1.xml
  # def destroy
  #   @bid = Bid.find(params[:id])
  #   @bid.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(bids_url) }
  #     format.xml  { head :ok }
  #   end
  # end
end
