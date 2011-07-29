require 'spec_helper'

describe "fund_deposits/edit.html.haml" do
  before(:each) do
    @fund_deposit = assign(:fund_deposit, stub_model(FundDeposit))
  end

  it "renders the edit fund_deposit form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => fund_deposits_path(@fund_deposit), :method => "post" do
    end
  end
end
