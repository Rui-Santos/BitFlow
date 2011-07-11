class AsksController < ApplicationController
  def index
    @asks = current_user.asks

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @ask = Ask.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @ask = Ask.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @ask = Ask.find(params[:id])
  end

  def create
    @ask = Ask.new(:user_id => current_user.id, 
                   :amount => params[:bid][:amount], 
                   :price => params[:bid][:price], 
                   :currency => params[:bid][:currency], 
                   :status => Order::Status::ACTIVE)

    respond_to do |format|
      if @ask.save
        format.html { redirect_to(@ask, :notice => 'Ask was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # # PUT /asks/1
  #  # PUT /asks/1.xml
  #  def update
  #    @ask = Ask.find(params[:id])
  # 
  #    respond_to do |format|
  #      if @ask.update_attributes(params[:ask])
  #        format.html { redirect_to(@ask, :notice => 'Ask was successfully updated.') }
  #        format.xml  { head :ok }
  #      else
  #        format.html { render :action => "edit" }
  #        format.xml  { render :xml => @ask.errors, :status => :unprocessable_entity }
  #      end
  #    end
  #  end
  # 
  #  # DELETE /asks/1
  #  # DELETE /asks/1.xml
  #  def destroy
  #    @ask = Ask.find(params[:id])
  #    @ask.destroy
  # 
  #    respond_to do |format|
  #      format.html { redirect_to(asks_url) }
  #      format.xml  { head :ok }
  #    end
  #  end
end
