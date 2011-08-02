require "spec_helper"

describe UserWalletsController do
  describe "routing" do

    it "routes to #index" do
      get("/user_wallets").should route_to("user_wallets#index")
    end

    it "routes to #new" do
      get("/user_wallets/new").should route_to("user_wallets#new")
    end

    it "routes to #show" do
      get("/user_wallets/1").should route_to("user_wallets#show", :id => "1")
    end

    it "routes to #edit" do
      get("/user_wallets/1/edit").should route_to("user_wallets#edit", :id => "1")
    end

    it "routes to #create" do
      post("/user_wallets").should route_to("user_wallets#create")
    end

    it "routes to #update" do
      put("/user_wallets/1").should route_to("user_wallets#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/user_wallets/1").should route_to("user_wallets#destroy", :id => "1")
    end

  end
end
