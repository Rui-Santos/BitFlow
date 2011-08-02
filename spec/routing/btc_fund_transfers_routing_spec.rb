require "spec_helper"

describe BtcFundTransfersController do
  describe "routing" do

    it "routes to #index" do
      get("/btc_fund_transfers").should route_to("btc_fund_transfers#index")
    end

    it "routes to #new" do
      get("/btc_fund_transfers/new").should route_to("btc_fund_transfers#new")
    end

    it "routes to #show" do
      get("/btc_fund_transfers/1").should route_to("btc_fund_transfers#show", :id => "1")
    end

    it "routes to #edit" do
      get("/btc_fund_transfers/1/edit").should route_to("btc_fund_transfers#edit", :id => "1")
    end

    it "routes to #create" do
      post("/btc_fund_transfers").should route_to("btc_fund_transfers#create")
    end

    it "routes to #update" do
      put("/btc_fund_transfers/1").should route_to("btc_fund_transfers#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/btc_fund_transfers/1").should route_to("btc_fund_transfers#destroy", :id => "1")
    end

  end
end
