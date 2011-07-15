class TradesController < ApplicationController
  def index
    @trades = Trade.all(:include => [:bids,:asks])
    respond_to do |format|
      format.html # index.html.erb
    end
  end

end
