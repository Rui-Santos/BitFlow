require "spec_helper"

describe BankaccountsController do
  describe "routing" do

    it "routes to #index" do
      get("/bankaccounts").should route_to("bankaccounts#index")
    end

    it "routes to #new" do
      get("/bankaccounts/new").should route_to("bankaccounts#new")
    end

    it "routes to #show" do
      get("/bankaccounts/1").should route_to("bankaccounts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/bankaccounts/1/edit").should route_to("bankaccounts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/bankaccounts").should route_to("bankaccounts#create")
    end

    it "routes to #update" do
      put("/bankaccounts/1").should route_to("bankaccounts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/bankaccounts/1").should route_to("bankaccounts#destroy", :id => "1")
    end

  end
end
