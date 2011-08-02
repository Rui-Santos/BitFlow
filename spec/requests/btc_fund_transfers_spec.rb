require 'spec_helper'

describe "BtcFundTransfers" do
  describe "GET /btc_fund_transfers" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get btc_fund_transfers_path
      response.status.should be(200)
    end
  end
end
