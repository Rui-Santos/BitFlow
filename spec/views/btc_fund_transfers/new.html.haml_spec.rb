require 'spec_helper'

describe "btc_fund_transfers/new.html.haml" do
  before(:each) do
    assign(:btc_fund_transfer, stub_model(BtcFundTransfer).as_new_record)
  end

  it "renders new btc_fund_transfer form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => btc_fund_transfers_path, :method => "post" do
    end
  end
end
