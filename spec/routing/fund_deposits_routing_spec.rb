require "spec_helper"

describe FundDepositsController do
  describe "routing" do

    it "routes to #index" do
      get("/fund_deposits").should route_to("fund_deposits#index")
    end

    it "routes to #new" do
      get("/fund_deposits/new").should route_to("fund_deposits#new")
    end

    it "routes to #show" do
      get("/fund_deposits/1").should route_to("fund_deposits#show", :id => "1")
    end

    it "routes to #edit" do
      get("/fund_deposits/1/edit").should route_to("fund_deposits#edit", :id => "1")
    end

    it "routes to #create" do
      post("/fund_deposits").should route_to("fund_deposits#create")
    end

    it "routes to #update" do
      put("/fund_deposits/1").should route_to("fund_deposits#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/fund_deposits/1").should route_to("fund_deposits#destroy", :id => "1")
    end

  end
end
